# Find lines beginning with a single space. Insert a newline above and then delete the space.
/^ [A-Z@\^]/{
i \

s/ //
}
