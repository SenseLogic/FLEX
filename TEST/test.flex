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
SetPascalCase
Edit folder
ReplacePrefix IN/ OUT/
DumpChangedFiles
DumpChangedLines
WriteFiles
