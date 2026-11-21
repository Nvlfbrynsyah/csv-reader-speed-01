export function run(input) {
  const text = String(input.text);
  const header = input.header === true;
  const errors = [];
  const rows = [];
  let columns = null;
  let width = -1;

  const len = text.length;
  let pos = 0;
  let line = 1;

  if (len > 0 && text.charCodeAt(0) === 0xFEFF) {
    pos = 1;
  }

  while (pos < len) {
    // Skip blank lines
    while (pos < len) {
      const code = text.charCodeAt(pos);
      if (code === 10) {
        pos++;
        line++;
      } else if (code === 13) {
        if (pos + 1 < len && text.charCodeAt(pos + 1) === 10) {
          pos += 2;
          line++;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    if (pos >= len) break;

    const recordLine = line;
    const recordRow = header && columns === null ? null : rows.length;

    const fields = [];
    let fieldEnded = false;
    let lastWasQuoted = false;

    while (!fieldEnded) {
      const isQuoted = pos < len && text.charCodeAt(pos) === 34;

      if (isQuoted) {
        lastWasQuoted = true;
        const openPos = pos;
        const openLine = line;
        pos++; // skip opening quote

        // Find closing quote (handling doubled quotes "")
        let closePos = pos;
        while (true) {
          closePos = text.indexOf('"', closePos);
          if (closePos === -1) break;
          if (closePos + 1 < len && text.charCodeAt(closePos + 1) === 34) {
            closePos += 2;
            continue;
          }
          break;
        }

        if (closePos === -1) {
          // Unterminated quote
          pos = openPos + 1;
          line = openLine;
          errors.push({ code: 'unterminated_quote', line: recordLine, row: recordRow });
          // Read as unquoted starting with '"'
          let uval = '"';
          let ended = 'end';
          while (pos < len) {
            const nextComma = text.indexOf(',', pos);
            const nextLf = text.indexOf('\n', pos);
            let next = len;
            if (nextComma !== -1 && nextComma < next) next = nextComma;
            if (nextLf !== -1 && nextLf < next) next = nextLf;
            const nextCr = text.indexOf('\r', pos);
            if (nextCr !== -1 && nextCr < next) {
              const chunk = text.slice(pos, nextCr);
              uval += chunk;
              if (nextCr + 1 < len && text.charCodeAt(nextCr + 1) === 10) {
                pos = nextCr + 2;
                line++;
                ended = 'line break';
                break;
              } else {
                errors.push({ code: 'stray_cr', line: recordLine, row: recordRow });
                pos = nextCr + 1;
                continue;
              }
            }
            const chunk = text.slice(pos, next);
            uval += chunk;
            if (next === len) {
              pos = len;
              ended = 'end';
              break;
            }
            const code = text.charCodeAt(next);
            if (code === 44) {
              pos = next + 1;
              ended = 'comma';
              break;
            } else {
              pos = next + 1;
              line++;
              ended = 'line break';
              break;
            }
          }
          fields.push(uval);
          fieldEnded = (ended !== 'comma');
        } else {
          const raw = text.slice(pos, closePos);
          pos = closePos + 1; // skip closing quote

          let val;
          // Quoted field fast path: if raw has no '"' and no '\r'
          if (raw.indexOf('"') === -1 && raw.indexOf('\r') === -1) {
            val = raw;
            // Count newlines in raw efficiently
            let nlIdx = raw.indexOf('\n');
            if (nlIdx !== -1) {
              line++;
              while ((nlIdx = raw.indexOf('\n', nlIdx + 1)) !== -1) {
                line++;
              }
            }
          } else {
            // Careful per-char path
            val = '';
            let i = 0;
            const rLen = raw.length;
            while (i < rLen) {
              const c = raw.charCodeAt(i);
              if (c === 34 && i + 1 < rLen && raw.charCodeAt(i + 1) === 34) {
                val += '"';
                i += 2;
                continue;
              }
              if (c === 13) {
                val += '\n';
                line++;
                if (i + 1 < rLen && raw.charCodeAt(i + 1) === 10) {
                  i += 2;
                } else {
                  i++;
                }
                continue;
              }
              if (c === 10) {
                line++;
              }
              val += raw[i];
              i++;
            }
          }

          // Check what follows closing quote up to comma or line break
          let junkAdded = 0;
          let ended = 'end';
          if (pos < len) {
            const nc = text.charCodeAt(pos);
            if (nc === 44) {
              pos++;
              ended = 'comma';
            } else if (nc === 10) {
              pos++;
              line++;
              ended = 'line break';
            } else if (nc === 13) {
              if (pos + 1 < len && text.charCodeAt(pos + 1) === 10) {
                pos += 2;
                line++;
                ended = 'line break';
              } else {
                errors.push({ code: 'stray_cr', line: recordLine, row: recordRow });
                pos++;
                let junkRes = readUnquotedText();
                if (junkRes.added > 0) junkAdded = junkRes.added;
                ended = junkRes.ended;
              }
            } else {
              let junkRes = readUnquotedText();
              if (junkRes.added > 0) {
                junkAdded = junkRes.added;
                val += junkRes.value;
              }
              ended = junkRes.ended;
            }
          }
          if (junkAdded > 0) {
            errors.push({ code: 'quote_junk', line: recordLine, row: recordRow });
          }
          fields.push(val);
          fieldEnded = (ended !== 'comma');
        }
      } else {
        lastWasQuoted = false;
        // Fast unquoted field scan using indexOf
        let val = '';
        while (pos < len) {
          const nextComma = text.indexOf(',', pos);
          const nextLf = text.indexOf('\n', pos);

          let next = len;
          if (nextComma !== -1 && nextComma < next) next = nextComma;
          if (nextLf !== -1 && nextLf < next) next = nextLf;

          const nextCr = text.indexOf('\r', pos);
          if (nextCr !== -1 && nextCr < next) {
            const chunk = text.slice(pos, nextCr);
            val += chunk;
            if (nextCr + 1 < len && text.charCodeAt(nextCr + 1) === 10) {
              pos = nextCr + 2;
              line++;
              fieldEnded = true;
              break;
            } else {
              errors.push({ code: 'stray_cr', line: recordLine, row: recordRow });
              pos = nextCr + 1;
              continue;
            }
          }

          const chunk = text.slice(pos, next);
          val += chunk;

          if (next === len) {
            pos = len;
            fieldEnded = true;
            break;
          }

          const code = text.charCodeAt(next);
          if (code === 44) {
            pos = next + 1;
            fieldEnded = false;
            break;
          } else {
            pos = next + 1;
            line++;
            fieldEnded = true;
            break;
          }
        }
        fields.push(val);
      }
    }

    function readUnquotedText() {
      let uval = '';
      let added = 0;
      let ended = 'end';
      while (pos < len) {
        const nextComma = text.indexOf(',', pos);
        const nextLf = text.indexOf('\n', pos);

        let next = len;
        if (nextComma !== -1 && nextComma < next) next = nextComma;
        if (nextLf !== -1 && nextLf < next) next = nextLf;

        const nextCr = text.indexOf('\r', pos);
        if (nextCr !== -1 && nextCr < next) {
          const chunk = text.slice(pos, nextCr);
          uval += chunk;
          added += chunk.length;
          if (nextCr + 1 < len && text.charCodeAt(nextCr + 1) === 10) {
            pos = nextCr + 2;
            line++;
            ended = 'line break';
            break;
          } else {
            errors.push({ code: 'stray_cr', line: recordLine, row: recordRow });
            pos = nextCr + 1;
            continue;
          }
        }

        const chunk = text.slice(pos, next);
        uval += chunk;
        added += chunk.length;

        if (next === len) {
          pos = len;
          ended = 'end';
          break;
        }

        const code = text.charCodeAt(next);
        if (code === 44) {
          pos = next + 1;
          ended = 'comma';
          break;
        } else {
          pos = next + 1;
          line++;
          ended = 'line break';
          break;
        }
      }
      return { value: uval, added, ended };
    }

    if (fields.length === 1 && fields[0] === '' && !lastWasQuoted) {
      continue;
    }

    if (width < 0) width = fields.length;
    if (header && columns === null) {
      columns = fields;
      continue;
    }
    if (fields.length < width) {
      errors.push({ code: 'short_row', line: recordLine, row: recordRow, fields: fields.length });
      while (fields.length < width) fields.push('');
    } else if (fields.length > width) {
      errors.push({ code: 'long_row', line: recordLine, row: recordRow, extra: fields.splice(width) });
    }
    rows.push(fields);
  }

  return { columns: header ? (columns ?? []) : null, rows, errors };
}
