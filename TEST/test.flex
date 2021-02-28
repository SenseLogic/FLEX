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
