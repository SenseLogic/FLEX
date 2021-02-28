![](https://github.com/senselogic/FLEX/blob/master/LOGO/flex.png)

# Flex

Text file processor.

## Sample

```bash
IncludeFiles .//*.*
ExcludeFiles *.jpg *.png *.svg *.mp4
ReadFiles
Edit name
ReplacePrefix prefix_ start_
ReplaceSuffix _suffix _end
Edit name text
ReplaceText old_text new_text
ReplaceQuotedText old_quoted_text new_quoted_text
ReplaceUnquotedText old_unquoted_text new_unquoted_text
ReplaceIdentifier old_identifier new_identifier
ReplaceExpression
    old_([A-Z]+)_expression
    new_$1_expression
WriteFiles
```

### Commands

```bash
IncludeFiles <file path filter> ...
ExcludeFiles <file name filter> ...
SelectFiles <file name filter> ...
IgnoreFiles <file name filter> ...
ReadFiles
Edit [folder] [name] [text]
AddPrefix <prefix>
RemovePrefix <prefix>
ReplacePrefix <old prefix> <new prefix>
AddSuffix <suffix>
RemoveSuffix <suffix>
ReplaceSuffix <old suffix> <new suffix>
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
WriteFiles
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
