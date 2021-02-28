/*
    This file is part of the Flex distribution.

    https://github.com/senselogic/FLEX

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Flex is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Flex is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Flex.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.algorithm: sort;
import std.conv : to;
import std.file : dirEntries, exists, mkdirRecurse, readText, remove, rmdir, write, SpanMode;
import std.path : globMatch;
import std.regex : regex, replaceAll;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, stripRight;

// -- TYPES

class COMMAND
{
    // -- ATTRIBUTES

    string
        Name;
    string[]
        ArgumentArray;

    // -- CONSTRUCTORS

    this(
        string name,
        string[] argument_array
        )
    {
        Name = name;
        ArgumentArray = argument_array;
    }

    // -- INQUIRIES

    string GetText(
        )
    {
        return Name ~ " " ~ ArgumentArray.join( ' ' );
    }

    // ~~

    string Execute(
        string text
        )
    {
        if ( Name == "AddPrefix"
             && ArgumentArray.length == 1 )
        {
            return text.AddPrefix( ArgumentArray[ 0 ] );
        }
        else if ( Name == "RemovePrefix"
                  && ArgumentArray.length == 1 )
        {
            return text.RemovePrefix( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplacePrefix"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplacePrefix( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "AddSuffix"
                  && ArgumentArray.length == 1 )
        {
            return text.AddSuffix( ArgumentArray[ 0 ] );
        }
        else if ( Name == "RemoveSuffix"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveSuffix( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceSuffix"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceSuffix( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "RemoveText"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveText( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceText"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceText( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "RemoveUnquotedText"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveUnquotedText( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceUnquotedText"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceUnquotedText( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "RemoveQuotedText"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveQuotedText( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceQuotedText"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceQuotedText( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "RemoveIdentifier"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveIdentifier( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceIdentifier"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceIdentifier( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else if ( Name == "RemoveExpression"
                  && ArgumentArray.length == 1 )
        {
            return text.RemoveExpression( ArgumentArray[ 0 ] );
        }
        else if ( Name == "ReplaceExpression"
                  && ArgumentArray.length == 2 )
        {
            return text.ReplaceExpression( ArgumentArray[ 0 ], ArgumentArray[ 1 ] );
        }
        else
        {
            Abort( "Invalid command : " ~ GetText() );
        }

        return "";
    }
}

// ~~

class FILE
{
    // -- ATTRIBUTES

    string
        Path,
        Folder,
        Label,
        Extension,
        Text;
    string[ string ]
        PropertyMap;
    bool
        IsSelected,
        IsRead,
        IsRemoved;

    // -- CONSTRUCTORS

    this(
        string file_path
        )
    {
        Path = file_path;
        Path.SplitFilePath( Folder, Label, Extension );

        PropertyMap[ "folder" ] = Folder;
        PropertyMap[ "label" ] = Label;
        PropertyMap[ "extension" ] = Extension;
        PropertyMap[ "text" ] = "";

        IsSelected = true;
    }

    // -- INQUIRIES

    string GetFolder(
        )
    {
        return PropertyMap[ "folder" ];
    }

    // ~~

    string GetLabel(
        )
    {
        return PropertyMap[ "label" ];
    }

    // ~~

    string GetExtension(
        )
    {
        return PropertyMap[ "extension" ];
    }

    // ~~

    string GetText(
        )
    {
        return PropertyMap[ "text" ];
    }

    // ~~

    string GetName(
        )
    {
        return PropertyMap[ "label" ] ~ PropertyMap[ "extension" ];
    }

    // ~~

    string GetPath(
        )
    {
        return PropertyMap[ "folder" ] ~ GetName();
    }

    // ~~

    bool HasChangedPath(
        )
    {
        return GetPath() != Path;
    }

    // ~~

    bool HasChangedText(
        )
    {
        return GetText() != Text;
    }

    // ~~

    bool HasChanged(
        )
    {
        return
            HasChangedPath()
            || HasChangedText();
    }

    // ~~

    bool MatchesFilePathFilter(
        string file_path_filter
        )
    {
        return GetPath().globMatch( file_path_filter );
    }

    // -- OPERATIONS

    void Read(
        )
    {
        Text = Path.ReadText();
        PropertyMap[ "text" ] = Text;
        IsRead = true;
    }

    // ~~

    void List(
        bool file_has_changed,
        string prefix = ""
        )
    {
        if ( !file_has_changed
             || HasChanged() )
        {
            writeln( prefix ~ GetPath() );
        }
    }

    // ~~

    void Dump(
        bool file_has_changed
        )
    {
        if ( !file_has_changed
             || HasChanged() )
        {
            writeln( "---" ~ prefix ~ GetPath() );
            writeln( GetText() );
        }
    }

    // ~~

    void Write(
        bool file_is_moved = false
        )
    {
        string
            file_path,
            file_text;

        if ( IsRead )
        {
            file_path = GetPath();
            file_text = GetText();

            if ( file_path != Path
                 || file_text != Text )
            {
                if ( file_path != Path
                     && file_is_moved )
                {
                    Path.RemoveFile();
                }

                file_path.WriteText( file_text );
            }

            IsRead = false;
        }
        else
        {
            Abort( "File is not read : " ~ GetPath() );
        }
    }

    // ~~

    void Move(
        )
    {
        Write( true );
    }
}

// ~~

class SCRIPT
{
    // -- ATTRIBUTES

    COMMAND[]
        CommandArray;
    string[]
        PropertyNameArray;
    FILE[ string ]
        FileMap;

    // -- INQUIRIES

    string GetProcessedLine(
        string line
        )
    {
        char
            character;
        string
            processed_line;

        foreach ( character_index; 0 .. line.length )
        {
            character = line[ character_index ];

            if ( character == '\\'
                 && character_index + 1 < line.length )
            {
                ++character_index;
                character = line[ character_index ];

                if ( character == 'n' )
                {
                    processed_line ~= '\n';
                }
                else if ( character == 'r' )
                {
                    processed_line ~= '\r';
                }
                else if ( character == 't' )
                {
                    processed_line ~= '\t';
                }
                else if ( character != '-' )
                {
                    processed_line ~= character;
                }
            }
            else
            {
                processed_line ~= character;
            }
        }

        return processed_line;
    }

    // ~~

    FILE[] GetSortedFileArray(
        )
    {
        FILE[]
            sorted_file_array;

        foreach ( file; FileMap )
        {
            sorted_file_array ~= file;
        }

        sorted_file_array.sort!(
            ( first_file, second_file )
            => ( first_file.GetFolder() < second_file.GetFolder()
                 || ( first_file.GetFolder() == second_file.GetFolder()
                      && first_file.GetName() < second_file.GetName() ) )
            )();

        return sorted_file_array;
    }

    // -- OPERATIONS

    void SetPropertyNameArray(
        string[] property_name_array
        )
    {
        PropertyNameArray = [];

        foreach ( property_name; property_name_array )
        {
            if ( property_name == "folder"
                 || property_name == "label"
                 || property_name == "extension"
                 || property_name == "text" )
            {
                PropertyNameArray ~= property_name;
            }
            else
            {
                Abort( "Invalid property name : " ~ property_name );
            }
        }
    }

    // ~~

    void IncludeFiles(
        string[] file_path_filter_array
        )
    {
        string
            file_name_filter,
            file_path,
            folder_path;
        SpanMode
            span_mode;

        foreach ( file_path_filter; file_path_filter_array )
        {
            SplitFilePathFilter( file_path_filter, folder_path, file_name_filter, span_mode );

            foreach ( folder_entry; dirEntries( folder_path, file_name_filter, span_mode ) )
            {
                if ( folder_entry.isFile )
                {
                    file_path = folder_entry.name;

                    if ( ( file_path in FileMap ) is null )
                    {
                        writeln( "Including file : " ~ file_path );

                        FileMap[ file_path ] = new FILE( file_path );
                    }
                }
            }
        }
    }

    // ~~

    void ExcludeFiles(
        string[] file_path_filter_array
        )
    {
        string[]
            excluded_file_path_array;

        if ( file_path_filter_array.length > 0 )
        {
            foreach ( file; FileMap )
            {
                foreach ( file_path_filter; file_path_filter_array )
                {
                    if ( file.MatchesFilePathFilter( file_path_filter ) )
                    {
                        excluded_file_path_array ~= file.Path;

                        break;
                    }
                }
            }

            foreach ( excluded_file_path; excluded_file_path_array )
            {
                writeln( "Excluding file : " ~ excluded_file_path );

                FileMap.remove( excluded_file_path );
            }
        }
        else
        {
            FileMap = null;
        }
    }

    // ~~

    void SelectFiles(
        string[] file_path_filter_array
        )
    {
        string[]
            excluded_file_path_array;

        foreach ( file; FileMap )
        {
            if ( file_path_filter_array.length > 0 )
            {
                foreach ( file_path_filter; file_path_filter_array )
                {
                    if ( file.MatchesFilePathFilter( file_path_filter ) )
                    {
                        writeln( "Selecting file : " ~ file.Path );

                        file.IsSelected = true;

                        break;
                    }
                }
            }
            else
            {
                writeln( "Selecting file : " ~ file.Path );

                file.IsSelected = true;
            }
        }
    }

    // ~~

    void IgnoreFiles(
        string[] file_path_filter_array
        )
    {
        string[]
            excluded_file_path_array;

        foreach ( file; FileMap )
        {
            if ( file_path_filter_array.length > 0 )
            {
                foreach ( file_path_filter; file_path_filter_array )
                {
                    if ( file.MatchesFilePathFilter( file_path_filter ) )
                    {
                        writeln( "Ignoring file : " ~ file.Path );

                        file.IsSelected = false;

                        break;
                    }
                }
            }
            else
            {
                writeln( "Ignoring file : " ~ file.Path );

                file.IsSelected = false;
            }
        }
    }

    // ~~

    void ReadFiles(
        )
    {
        foreach ( file; FileMap )
        {
            file.Read();
        }
    }

    // ~~

    void ListFiles(
        )
    {
        foreach ( file; GetSortedFileArray() )
        {
            file.List( false );
        }
    }

    // ~~

    void ListChangedFiles(
        )
    {
        foreach ( file; GetSortedFileArray() )
        {
            file.List( true );
        }
    }

    // ~~

    void DumpFiles(
        )
    {
        foreach ( file; GetSortedFileArray() )
        {
            file.Dump( false );
        }
    }

    // ~~

    void DumpChangedFiles(
        )
    {
        foreach ( file; GetSortedFileArray() )
        {
            file.Dump( true );
        }
    }

    // ~~

    void WriteFiles(
        )
    {
        foreach ( file; FileMap )
        {
            file.Write();
        }
    }

    // ~~

    void MoveFiles(
        )
    {
        foreach ( file; FileMap )
        {
            file.Move();
        }
    }

    // ~~

    void Load(
        string file_path
        )
    {
        string
            line;
        string[]
            line_array,
            part_array;

        if ( file_path.exists() )
        {
            line_array = file_path.ReadText().replace( "\r", "" ).replace( "\t", "    " ).split( '\n' );

            foreach ( line_index; 0 .. line_array.length )
            {
                line = line_array[ line_index ].stripRight();
                writeln( line );

                if ( line.length > 0
                     && line[ 0 ] != '#' )
                {
                    if ( line.startsWith( "    " ) )
                    {
                        if ( CommandArray.length > 0 )
                        {
                            CommandArray[ $ - 1 ].ArgumentArray ~= GetProcessedLine( line[ 4 .. $ ] );
                        }
                        else
                        {
                            Abort( "Invalid command : " ~ line );
                        }
                    }
                    else
                    {
                        part_array = GetProcessedLine( line ).split( ' ' );
                        CommandArray ~= new COMMAND( part_array[ 0 ], part_array[ 1 .. $ ] );
                    }
                }
            }

            PropertyNameArray = [ "text" ];
        }
        else
        {
            Abort( "Invalid file path : " ~ file_path );
        }
    }

    // ~~

    void Execute(
        )
    {
        foreach ( command; CommandArray )
        {
            writeln( command.GetText() );

            if ( command.Name == "Edit" )
            {
                SetPropertyNameArray( command.ArgumentArray );
            }
            else if ( command.Name == "IncludeFiles"
                      && command.ArgumentArray.length >= 1 )
            {
                IncludeFiles( command.ArgumentArray.GetLogicalPathArray() );
            }
            else if ( command.Name == "ExcludeFiles" )
            {
                ExcludeFiles( command.ArgumentArray.GetLogicalPathArray() );
            }
            else if ( command.Name == "SelectFiles" )
            {
                SelectFiles( command.ArgumentArray.GetLogicalPathArray() );
            }
            else if ( command.Name == "IgnoreFiles" )
            {
                IgnoreFiles( command.ArgumentArray.GetLogicalPathArray() );
            }
            else if ( command.Name == "ReadFiles"
                      && command.ArgumentArray.length == 0 )
            {
                ReadFiles();
            }
            else if ( command.Name == "ListFiles"
                      && command.ArgumentArray.length == 0 )
            {
                ListFiles();
            }
            else if ( command.Name == "ListChangedFiles"
                      && command.ArgumentArray.length == 0 )
            {
                ListChangedFiles();
            }
            else if ( command.Name == "DumpFiles"
                      && command.ArgumentArray.length == 0 )
            {
                DumpFiles();
            }
            else if ( command.Name == "DumpChangedFiles"
                      && command.ArgumentArray.length == 0 )
            {
                DumpChangedFiles();
            }
            else if ( command.Name == "WriteFiles"
                      && command.ArgumentArray.length == 0 )
            {
                WriteFiles();
            }
            else if ( command.Name == "MoveFiles"
                      && command.ArgumentArray.length == 0 )
            {
                MoveFiles();
            }
            else
            {
                foreach ( file; FileMap )
                {
                    if ( file.IsSelected )
                    {
                        foreach ( property_name; PropertyNameArray )
                        {
                            file.PropertyMap[ property_name ] = command.Execute( file.PropertyMap[ property_name ] );
                        }
                    }
                }
            }
        }
    }
}

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

bool IsNatural(
    string text
    )
{
    if ( text.length > 0 )
    {
        foreach ( character; text )
        {
            if ( character < '0'
                 || character > '9' )
            {
                return false;
            }
        }

        return true;
    }

    return false;
}

// ~~

bool IsInteger(
    string text
    )
{
    if ( text.length > 0
         && text[ 0 ] == '-' )
    {
        text = text[ 1 .. $ ];
    }

    return text.IsNatural();
}

// ~~

long GetInteger(
    string text
    )
{
    if ( text.IsInteger() )
    {
        return text.to!long();
    }

    Abort( "Invalid integer : " ~ text );

    return 0;
}

// ~~

bool IsIdentifierCharacter(
    char character
    )
{
    return
        ( character >= 'a' && character <= 'z' )
        || ( character >= 'A' && character <= 'Z' )
        || ( character >= '0' && character <= '9' )
        || character == '_';
}

// ~~

bool IsIdentifier(
    string text
    )
{
    if ( text.length > 0 )
    {
        if ( text[ 0 ] >= '0'
             && text[ 0 ] <= '9' )
        {
            return false;
        }

        foreach ( character; text )
        {
            if ( !IsIdentifierCharacter( character ) )
            {
                return false;
            }
        }

        return true;
    }

    return false;
}

// ~~

bool IsQuoteCharacter(
    char character
    )
{
    return
        character == '\''
        || character == '\"'
        || character == '`';
}

// ~~

bool IsLowerCaseLetter(
    dchar character
    )
{
    return
        ( character >= 'a' && character <= 'z' )
        || character == 'à'
        || character == 'â'
        || character == 'é'
        || character == 'è'
        || character == 'ê'
        || character == 'ë'
        || character == 'î'
        || character == 'ï'
        || character == 'ô'
        || character == 'ö'
        || character == 'û'
        || character == 'ü'
        || character == 'ç'
        || character == 'ñ';
}

// ~~

bool IsUpperCaseLetter(
    dchar character
    )
{
    return
        ( character >= 'A' && character <= 'Z' )
        || character == 'À'
        || character == 'Â'
        || character == 'É'
        || character == 'È'
        || character == 'Ê'
        || character == 'Ë'
        || character == 'Î'
        || character == 'Ï'
        || character == 'Ô'
        || character == 'Ö'
        || character == 'Û'
        || character == 'Ü'
        || character == 'Ñ';
}

// ~~

bool IsSetter(
    dchar character
    )
{
    return
        IsLowerCaseLetter( character )
        || IsUpperCaseLetter( character );
}

// ~~

bool IsDigit(
    dchar character
    )
{
    return character >= '0' && character <= '9';
}

// ~~

dchar GetLowerCaseCharacter(
    dchar character
    )
{
    if ( character >= 'A' && character <= 'Z' )
    {
        return 'a' + ( character - 'A' );
    }
    else
    {
        switch ( character )
        {
            case 'À' : return 'à';
            case 'Â' : return 'â';
            case 'É' : return 'é';
            case 'È' : return 'è';
            case 'Ê' : return 'ê';
            case 'Ë' : return 'ë';
            case 'Î' : return 'î';
            case 'Ï' : return 'ï';
            case 'Ô' : return 'ô';
            case 'Ö' : return 'ö';
            case 'Û' : return 'û';
            case 'Ü' : return 'ü';
            case 'Ñ' : return 'ñ';

            default : return character;
        }
    }
}


// ~~

dchar GetUpperCaseCharacter(
    dchar character
    )
{
    if ( character >= 'a' && character <= 'z' )
    {
        return 'A' + ( character - 'a' );
    }
    else
    {
        switch ( character )
        {
            case 'à' : return 'À';
            case 'â' : return 'Â';
            case 'é' : return 'É';
            case 'è' : return 'È';
            case 'ê' : return 'Ê';
            case 'ë' : return 'Ë';
            case 'î' : return 'Î';
            case 'ï' : return 'Ï';
            case 'ô' : return 'Ô';
            case 'ö' : return 'Ö';
            case 'û' : return 'Û';
            case 'ü' : return 'Ü';
            case 'ç' : return 'C';
            case 'ñ' : return 'Ñ';

            default : return character;
        }
    }
}

// ~~

string GetLowerCaseText(
    string text
    )
{
    string
        lower_case_text;

    foreach ( dchar character; text )
    {
        lower_case_text ~= GetLowerCaseCharacter( character );
    }

    return lower_case_text;
}

// ~~

string GetUpperCaseText(
    string text
    )
{
    string
        upper_case_text;

    foreach ( dchar character; text )
    {
        upper_case_text ~= GetUpperCaseCharacter( character );
    }

    return upper_case_text;
}

// ~~

string GetMinorCaseText(
    string text
    )
{
    if ( text.length >= 2 )
    {
        return text[ 0 .. 1 ].GetLowerCaseText() ~ text[ 1 .. $ ];
    }
    else
    {
        return text.GetLowerCaseText();
    }
}

// ~~

string GetMajorCaseText(
    string text
    )
{
    if ( text.length >= 2 )
    {
        return text[ 0 .. 1 ].GetUpperCaseText() ~ text[ 1 .. $ ];
    }
    else
    {
        return text.GetUpperCaseText();
    }
}

// ~~

string GetCamelCaseText(
    string text
    )
{
    dchar
        prior_character;
    string
        camel_case_text;

    camel_case_text = "";

    prior_character = 0;

    foreach ( dchar character; text )
    {
        if ( character.IsLowerCaseLetter()
             && !prior_character.IsSetter() )
        {
            camel_case_text ~= character.GetUpperCaseCharacter();
        }
        else
        {
            camel_case_text ~= character;
        }

        prior_character = character;
    }

    return camel_case_text;
}

// ~~

string GetSnakeCaseText(
    string text
    )
{
    dchar
        prior_character;
    string
        snake_case_text;

    snake_case_text = "";
    prior_character = 0;

    foreach ( dchar character; text )
    {
        if ( ( prior_character.IsLowerCaseLetter()
               && ( character.IsUpperCaseLetter()
                    || character.IsDigit() ) )
             || ( prior_character.IsDigit()
                  && ( character.IsLowerCaseLetter()
                       || character.IsUpperCaseLetter() ) ) )
        {
            snake_case_text ~= '_';
        }

        snake_case_text ~= character;

        prior_character = character;
    }

    return snake_case_text;
}

// ~~

string ReplaceTabulations(
    string line,
    long tabulation_space_count
    )
{
    char
        character;
    long
        character_index,
        line_character_index;
    string
        replaced_line;

    if ( tabulation_space_count > 0
         && line.indexOf( '\t' ) >= 0 )
    {
        replaced_line = "";

        line_character_index = 0;

        for ( character_index = 0;
              character_index < line.length;
              ++character_index )
        {
            character = line[ character_index ];

            if ( character == '\t' )
            {
                do
                {
                    replaced_line ~= ' ';

                    ++line_character_index;
                }
                while ( ( line_character_index % tabulation_space_count ) != 0 );
            }
            else
            {
                replaced_line ~= character;

                ++line_character_index;
            }
        }

        return replaced_line;
    }
    else
    {
        return line;
    }
}

// ~~

string ReplaceSpaces(
    string line,
    long tabulation_space_count
    )
{
    char
        character;
    long
        character_index;
    string
        replaced_line,
        tabulation_text;

    if ( tabulation_space_count > 0 )
    {
        tabulation_text = "        "[ 0 .. tabulation_space_count ];

        replaced_line = "";

        character_index = 0;

        while ( character_index < line.length )
        {
            character = line[ character_index ];

            if ( character == ' '
                 && ( replaced_line.length == 0
                      || replaced_line[ $ - 1 ] == '\t' )
                 && character_index + tabulation_space_count <= line.length
                 && line[ character_index .. character_index + tabulation_space_count ] == tabulation_text )
            {
                replaced_line ~= '\t';

                character_index += tabulation_space_count;
            }
            else
            {
                replaced_line ~= character;

                ++character_index;
            }
        }

        return replaced_line;
    }
    else
    {
        return line;
    }
}

// ~~

string AddPrefix(
    string text,
    string prefix
    )
{
    return prefix ~ text;
}

// ~~

string RemovePrefix(
    string text,
    string prefix
    )
{
    if ( text.startsWith( prefix ) )
    {
        return text[ prefix.length .. $ ];
    }
    else
    {
        return text;
    }
}

// ~~

string ReplacePrefix(
    string text,
    string old_prefix,
    string new_prefix
    )
{
    if ( text.startsWith( old_prefix ) )
    {
        return new_prefix ~ text[ old_prefix.length .. $ ];
    }
    else
    {
        return text;
    }
}

// ~~

string AddSuffix(
    string text,
    string suffix
    )
{
    return text ~ suffix;
}

// ~~

string RemoveSuffix(
    string text,
    string suffix
    )
{
    if ( text.endsWith( suffix ) )
    {
        return text[ 0 .. $ - suffix.length ];
    }
    else
    {
        return text;
    }
}

// ~~

string ReplaceSuffix(
    string text,
    string old_suffix,
    string new_suffix
    )
{
    if ( text.endsWith( old_suffix ) )
    {
        return text[ 0 .. $ - old_suffix.length ] ~ new_suffix;
    }
    else
    {
        return text;
    }
}

// ~~

string RemoveText(
    string text,
    string removed_text
    )
{
    return text.replace( removed_text, "" );
}

// ~~

string ReplaceText(
    string text,
    string old_text,
    string new_text
    )
{
    return text.replace( old_text, new_text );
}

// ~~

string ReplaceText(
    string text,
    string old_text,
    string new_text,
    bool old_text_must_be_unquoted,
    bool old_text_must_be_quoted,
    bool old_text_must_be_in_identifier
    )
{
    bool
        character_is_in_identifier,
        it_is_quoted;
    char
        character,
        prior_character,
        quote_character;
    long
        character_index;

    if ( old_text.length > 0
         && text.length >= old_text.length )
    {
        quote_character = 0;
        it_is_quoted = false;
        character_is_in_identifier = false;
        prior_character = 0;
        character_index = 0;

        while ( character_index + old_text.length <= text.length )
        {
            if ( text[ character_index .. character_index + old_text.length ] == old_text )
            {
                character_is_in_identifier
                    = ( old_text_must_be_in_identifier
                        && !IsIdentifierCharacter( prior_character )
                        && ( character_index + old_text.length >= text.length
                             || !IsIdentifierCharacter( text[ character_index + old_text.length ] ) ) );

                if ( ( !old_text_must_be_unquoted || !it_is_quoted )
                     && ( !old_text_must_be_quoted || it_is_quoted )
                     && ( !old_text_must_be_in_identifier || character_is_in_identifier ) )
                {
                    prior_character = text[ character_index + old_text.length.to!long() - 1 ];

                    text
                        = text[ 0 .. character_index ]
                          ~ new_text
                          ~ text[ character_index + old_text.length .. $ ];

                    character_index += new_text.length;

                    continue;
                }
            }

            character = text[ character_index ];
            prior_character = character;

            if ( it_is_quoted )
            {
                if ( character == quote_character )
                {
                    it_is_quoted = false;
                }
                else if ( character == '\\' )
                {
                    prior_character = character;

                    character_index += 2;

                    continue;
                }
            }
            else
            {
                if ( ( old_text_must_be_unquoted || old_text_must_be_quoted )
                     && IsQuoteCharacter( character ) )
                {
                    it_is_quoted = true;

                    quote_character = character;
                }
            }

            prior_character = text[ character_index ];

            ++character_index;
        }
    }

    return text;
}

// ~~

string RemoveUnquotedText(
    string text,
    string unquoted_text
    )
{
    return text.ReplaceText( unquoted_text, "", true, false, false );
}

// ~~

string ReplaceUnquotedText(
    string text,
    string old_unquoted_text,
    string new_unquoted_text
    )
{
    return text.ReplaceText( old_unquoted_text, new_unquoted_text, true, false, false );
}

// ~~

string RemoveQuotedText(
    string text,
    string quoted_text
    )
{
    return text.ReplaceText( quoted_text, "", false, true, false );
}

// ~~

string ReplaceQuotedText(
    string text,
    string old_quoted_text,
    string new_quoted_text
    )
{
    return text.ReplaceText( old_quoted_text, new_quoted_text, false, true, false );
}

// ~~

string RemoveIdentifier(
    string text,
    string identifier
    )
{
    return text.ReplaceText( identifier, "", false, false, true );
}

// ~~

string ReplaceIdentifier(
    string text,
    string old_identifier,
    string new_identifier
    )
{
    return text.ReplaceText( old_identifier, new_identifier, false, false, true );
}

// ~~

string RemoveExpression(
    string text,
    string expression
    )
{
    return text.replaceAll( regex( expression ), "" );
}

// ~~

string ReplaceExpression(
    string text,
    string old_expression,
    string new_expression
    )
{
    return text.replaceAll( regex( old_expression ), new_expression );
}

// ~~

bool IsFolderPath(
    string folder_path
    )
{
    return
        folder_path.endsWith( '/' )
        || folder_path.endsWith( '\\' );
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string[] GetLogicalPathArray(
    string[] path_array
    )
{
    string[]
        logical_path_array;

    foreach ( path; path_array )
    {
        logical_path_array ~= path.GetLogicalPath();
    }

    return logical_path_array;
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

void SplitFileName(
    string file_name,
    ref string file_label,
    ref string file_extension
    )
{
    long
        dot_character_index;

    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        file_label = file_name[ 0 .. dot_character_index ];
        file_extension = file_name[ dot_character_index .. $ ];
    }
    else
    {
        file_label = file_name;
        file_extension = "";
    }
}

// ~~

void SplitFilePath(
    string file_path,
    ref string folder_path,
    ref string file_name
    )
{
    long
        folder_path_character_count;

    folder_path_character_count = file_path.lastIndexOf( '/' ) + 1;

    folder_path = file_path[ 0 .. folder_path_character_count ];
    file_name = file_path[ folder_path_character_count .. $ ];
}

// ~~

void SplitFilePath(
    string file_path,
    ref string folder_path,
    ref string file_label,
    ref string file_extension
    )
{
    string
        file_name;

    SplitFilePath( file_path, folder_path, file_name );
    SplitFileName( file_name, file_label, file_extension );
}

// ~~

void SplitFilePathFilter(
    string file_path_filter,
    ref string folder_path,
    ref string file_name_filter,
    ref SpanMode span_mode
    )
{
    long
        folder_path_character_count;
    string
        file_name;

    folder_path_character_count = file_path_filter.lastIndexOf( '/' ) + 1;

    folder_path = file_path_filter[ 0 .. folder_path_character_count ];
    file_name_filter = file_path_filter[ folder_path_character_count .. $ ];

    if ( folder_path.endsWith( "//" ) )
    {
        folder_path = folder_path[ 0 .. $ - 1 ];

        span_mode = SpanMode.depth;
    }
    else
    {
        span_mode = SpanMode.shallow;
    }
}

// ~~

bool IsEmptyFolder(
    string folder_path
    )
{
    bool
        it_is_empty_folder;

    try
    {
        it_is_empty_folder = true;

        foreach ( folder_entry; dirEntries( folder_path, SpanMode.shallow ) )
        {
            it_is_empty_folder = false;

            break;
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't read folder : " ~ folder_path, exception );
    }

    return it_is_empty_folder;
}

// ~~

void CreateFolder(
    string folder_path
    )
{
    try
    {
        if ( folder_path != ""
             && folder_path != "/"
             && !folder_path.exists() )
        {
            writeln( "Creating folder : ", folder_path );

            folder_path.mkdirRecurse();
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void RemoveFolder(
    string folder_path
    )
{
    writeln( "Removing folder : ", folder_path );

    try
    {
        folder_path.rmdir();
    }
    catch ( Exception exception )
    {
        Abort( "Can't create folder : " ~ folder_path, exception );
    }
}

// ~~

void RemoveFile(
    string file_path
    )
{
    writeln( "Removing file : ", file_path );

    try
    {
        file_path.remove();
    }
    catch ( Exception exception )
    {
        Abort( "Can't remove file : " ~ file_path, exception );
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    CreateFolder( file_path.GetFolderPath() );

    writeln( "Writing file : ", file_path );

    try
    {
        if ( ( !file_path.exists()
               || file_path.readText() != file_text ) )
        {
            file_path.write( file_text );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

void ExecuteScript(
    string script_file_path
    )
{
    SCRIPT
        script;

    script = new SCRIPT();
    script.Load( script_file_path );
    script.Execute();
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        input_folder_path,
        option,
        output_folder_path;

    argument_array = argument_array[ 1 .. $ ];

    if ( argument_array.length == 1 )
    {
        ExecuteScript( argument_array[ 0 ] );
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    flex <script file path>" );
        writeln( "Examples :" );
        writeln( "    flex script.flex" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
