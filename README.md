![](https://github.com/senselogic/FLEX/blob/master/LOGO/flex.png)

# Flex

Text file processor.

## Sample

```bash
IncludeFiles IN//*.*
ExcludeFiles *.jpg *.png *.svg *.mp4
ReadFiles
Edit label text
ReplaceText old_text new_text
ReplaceQuotedText old_quoted_text new_quoted_text
ReplaceUnquotedText old_unquoted_text new_unquoted_text
ReplaceIdentifier old_identifier new_identifier
ReplaceExpression
    old_([A-Z]+)_expression
    new_$1_expression
Edit label
ReplacePrefix prefix_ start_
ReplaceSuffix _suffix _end
Edit folder
ReplacePrefix IN/ OUT/
DumpChangedFiles
DumpChangedLines
WriteFiles
```

### Commands

```bash
# comment
SetDefinition <definition name> <definition value>
ForEachDefinition <definition name> ... : <definition value> ...
End
IncludeFiles <file path filter> ...
ExcludeFiles [file name filter] ...
SelectFiles [file name filter] ...
IgnoreFiles [file name filter] ...
ReadFiles
Edit [folder] [label] [extension] [text]
AddPrefix <prefix>
RemovePrefix <prefix>
ReplacePrefix <old prefix> <new prefix>
AddSuffix <suffix>
RemoveSuffix <suffix>
ReplaceSuffix <old suffix> <new suffix>
SetText <text>
RemoveText <text>
ReplaceText <old text> <new text>
RemoveUnquotedText <unquoted text>
ReplaceUnquotedText <old unquoted text> <new unquoted text>
RemoveQuotedText <quoted text>
ReplaceQuotedText <old quoted text> <new quoted text>
RemoveIdentifier <identifier>
ReplaceIdentifier<old identifier> <new identifier>
RemoveExpression <expression>
ReplaceExpression <old expression> <new expression>
SetLowerCase
SetUpperCase
SetMinorCase
SetMajorCase
SetCamelCase
SetPascalCase
SetSnakeCase
SetKebabCase
SetTitleCase
ListFiles
ListChangedFiles
DumpFiles
DumpChangedFiles
DumpChangedLines [minimum same line count]
WriteFiles
MoveFiles
```

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 flex.d
```

## Command line

```
flex <script file path>
```

### Example

```bash
flex script.flex
```

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
