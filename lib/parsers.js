const fs = require('fs-extra');
const path = require('path');

/**
 * Parse a desc.e file to extract commentary metadata
 * @param {string} filePath - Path to the desc.e file
 * @returns {Object} Parsed commentary metadata
 */
function parseDescFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n').map(line => line.trim());
    
    const metadata = {};
    let currentField = null;
    let currentValue = '';
    
    for (const line of lines) {
      if (line.startsWith('..')) {
        // Save previous field
        if (currentField) {
          metadata[currentField] = currentValue.trim();
        }
        
        // Start new field
        const field = line.substring(2, line.indexOf(':', 2));
        currentField = field.toLowerCase();
        currentValue = line.substring(line.indexOf(':', 2) + 1).trim();
      } else if (currentField && line) {
        // Continue multi-line field
        currentValue += ' ' + line;
      }
    }
    
    // Save last field
    if (currentField) {
      metadata[currentField] = currentValue.trim();
    }
    
    return metadata;
  } catch (error) {
    console.error(`Error parsing desc file ${filePath}:`, error);
    return null;
  }
}

/**
 * Parse a text .e file to extract text segments
 * @param {string} filePath - Path to the .e file
 * @param {string} commId - Commentary ID
 * @param {string} cantica - Cantica name (inf/purg/para)
 * @param {string} cantoNum - Canto number or file identifier
 * @returns {Array} Array of text segments
 */
function parseTextFile(filePath, commId, cantica, cantoNum) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const segments = [];
    
    // Split content by segments marked with |
    const rawSegments = content.split(/\|\s*([^~]+)\.~/);
    
    for (let i = 1; i < rawSegments.length; i += 2) {
      const segmentHeader = rawSegments[i].trim();
      const segmentText = rawSegments[i + 1] ? rawSegments[i + 1].trim() : '';
      
      if (segmentText) {
        const segment = parseSegmentHeader(segmentHeader, segmentText, commId, cantica, cantoNum);
        if (segment) {
          segments.push(segment);
        }
      }
    }
    
    // Handle files without clear segment markers
    if (segments.length === 0 && content.trim()) {
      const fallbackSegment = {
        docId: generateDocId(commId, cantica, cantoNum, 0, 0),
        commId,
        cantica: mapCantica(cantica),
        cantoId: parseInt(cantoNum) || 0,
        startLine: 0,
        endLine: 0,
        textType: determineTextType(cantoNum, ''),
        content: content.trim()
      };
      segments.push(fallbackSegment);
    }
    
    return segments;
  } catch (error) {
    console.error(`Error parsing text file ${filePath}:`, error);
    return [];
  }
}

/**
 * Parse segment header to extract line information
 * @param {string} header - Segment header text
 * @param {string} content - Segment content
 * @param {string} commId - Commentary ID
 * @param {string} cantica - Cantica name
 * @param {string} cantoNum - Canto number
 * @returns {Object} Parsed segment
 */
function parseSegmentHeader(header, content, commId, cantica, cantoNum) {
  const segment = {
    commId,
    cantica: mapCantica(cantica),
    cantoId: parseInt(cantoNum) || 0,
    startLine: 0,
    endLine: 0,
    textType: 'commentary',
    content: content.trim()
  };
  
  // Parse line references like "1-3", "34-48", "Proemio", etc.
  const lineMatch = header.match(/(\d+)(?:-(\d+))?/);
  if (lineMatch) {
    segment.startLine = parseInt(lineMatch[1]);
    segment.endLine = parseInt(lineMatch[2]) || segment.startLine;
  }
  
  // Determine text type from header
  segment.textType = determineTextType(cantoNum, header);
  
  // Generate doc_id using original system
  segment.docId = generateDocId(
    commId, 
    cantica, 
    cantoNum, 
    segment.startLine, 
    0 // tie-breaker, will increment if needed
  );
  
  return segment;
}

/**
 * Generate doc_id using original 12-character system
 * Format: cccccannlllt
 * @param {string} commId - 5-char commentary ID
 * @param {string} cantica - Cantica abbreviation
 * @param {string} cantoNum - Canto number
 * @param {number} startLine - Starting line number
 * @param {number} tieBreaker - Tie-breaker digit
 * @returns {string} 12-character doc_id
 */
function generateDocId(commId, cantica, cantoNum, startLine, tieBreaker) {
  const canticaMap = { 'inf': '1', 'purg': '2', 'para': '3', 'general': '0' };
  const canticaId = canticaMap[cantica] || '0';
  const canto = String(parseInt(cantoNum) || 0).padStart(2, '0');
  const line = String(startLine).padStart(3, '0');
  const tie = String(tieBreaker);
  
  return commId + canticaId + canto + line + tie;
}

/**
 * Map cantica abbreviations to full names
 * @param {string} abbrev - Cantica abbreviation
 * @returns {string} Full cantica name
 */
function mapCantica(abbrev) {
  const map = {
    'inf': 'inferno',
    'purg': 'purgatorio', 
    'para': 'paradiso'
  };
  return map[abbrev] || 'general';
}

/**
 * Determine text type based on canto and header information
 * @param {string} cantoNum - Canto number or identifier
 * @param {string} header - Segment header
 * @returns {string} Text type
 */
function determineTextType(cantoNum, header) {
  const headerLower = header.toLowerCase();
  
  if (headerLower.includes('proemio') || headerLower.includes('summarium')) {
    return 'proemio';
  }
  if (headerLower.includes('conclusione')) {
    return 'conclusione';
  }
  if (cantoNum === 'comentum' || cantoNum === 'endnote') {
    return 'description';
  }
  
  return 'commentary';
}

/**
 * Map language codes from original system
 * @param {string} lang - Original language string
 * @returns {string} Normalized language code
 */
function mapLanguage(lang) {
  if (!lang) return 'latin';
  
  const langLower = lang.toLowerCase();
  if (langLower.includes('italian') || langLower.includes('italiano')) {
    return 'italian';
  }
  if (langLower.includes('english') || langLower.includes('american')) {
    return 'english';
  }
  return 'latin';
}

module.exports = {
  parseDescFile,
  parseTextFile,
  parseSegmentHeader,
  generateDocId,
  mapCantica,
  mapLanguage,
  determineTextType
};
