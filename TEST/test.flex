IncludeFiles IN//*.*
ExcludeFiles *.jpg *.png *.svg *.mp4
ExcludeFiles test.*
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

ForEachDefinition {first_name} {last_name} : 
    Harrison
    Ford 
    Rutger
    Hauer 
    Edward James
    Olmos
    Sean
    Young 
    Dary
    Hannah
ExcludeFiles
IncludeFiles IN//test.*
ReadFiles
Edit folder
ReplacePrefix IN/ OUT/
Edit label
SetText Test{first_name}{last_name}
RemoveText \s
Edit text
ReplaceText 
    FIRST NAME
    {first_name}
ReplaceText
    LAST NAME
    {last_name}
WriteFiles
End
