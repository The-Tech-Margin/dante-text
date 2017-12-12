BEGIN { FS = "}" }
/\b INFERNO|\b PURGATORIO|\bPARADISO/ {print}
