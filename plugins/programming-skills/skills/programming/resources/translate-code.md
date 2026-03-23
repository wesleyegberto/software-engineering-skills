# Translating code to a different programming language

There are many reasons why you might want to move code from one programming language to another. Each programming language has its own strengths and weaknesses, and you might want to take advantage of features that are available in another language. For example, you might want to move code to a language that has better performance, or which uses strong typing to help prevent bugs.

For ease of maintaining code, you might want to move code to a language that is more widely used in your organization. For example, if few people in your organization know an older language such as Perl, you might want to move any Perl code that's still in use to a more commonly used language such as Python or JavaScript.

You should help you translate code from one language to another. Translating a standalone file, such as a script, is straightforward. This process is described in this article.

## Example scenario

The following Perl script prompts the user to enter the path to a text file. It checks what the user enters and if a text file is found at that path, it outputs a word count and character count for the contents of the file.

```perl
#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use File::Basename;

print "Please enter the path to a local text file: ";
chomp(my $file_path = <STDIN>);

if ($file_path =~ /[`|;&<>(){}\[\]]/ || !File::Spec->file_name_is_absolute($file_path) && dirname($file_path) ne '.') {
    die "Invalid file path. Please provide a valid path.\n";
}
if (!-e $file_path) {
    die "File not found. Please provide an existing file path.\n";
}

open(my $fh, '<', $file_path) or die "Could not open file '$file_path': $!\n";

my $is_binary = 0;
while (read($fh, my $buffer, 1024)) {
    if ($buffer =~ /[^\x09\x0A\x0D\x20-\x7E]/) {
        $is_binary = 1;
        last;
    }
}
close($fh);

if ($is_binary) {
    die "The file '$file_path' is a binary file. Please provide a text file.\n";
}

open($fh, '<', $file_path) or die "Could not open file '$file_path': $!\n";
my $content = do { local $/; <$fh> };
close($fh);

my $word_count = scalar(split /\s+/, $content);
my $char_count = length($content);

print "The file '$file_path' contains $word_count words and $char_count characters.\n";
```

## Example prompt

```prompt
Tell me how I can convert this Perl script to Typescript. The functionality and output of the new script should be exactly the same as the existing one. Also tell me how to run the new file using Node.
```

## Example response

Generates the following Typescript code.

```typescript
import * as fs from 'fs';
import * as path from 'path';
import * as readline from 'readline';

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Please enter the path to a local text file: ', (filePath) => {
    rl.close();

    if (/[`|;&<>(){}\[\]]/.test(filePath) || (!path.isAbsolute(filePath) && path.dirname(filePath) !== '.')) {
        console.error('Invalid file path. Please provide a valid path.');
        process.exit(1);
    }

    if (!fs.existsSync(filePath)) {
        console.error('File not found. Please provide an existing file path.');
        process.exit(1);
    }

    const fileBuffer = fs.readFileSync(filePath);
    const isBinary = fileBuffer.some(byte => byte < 9 || (byte > 13 && byte < 32) || byte > 126);

    if (isBinary) {
        console.error(`The file '${filePath}' is a binary file. Please provide a text file.`);
        process.exit(1);
    }

    const content = fileBuffer.toString('utf-8');
    const wordCount = content.split(/\s+/).length;
    const charCount = content.length;

    console.log(`The file '${filePath}' contains ${wordCount} words and ${charCount} characters.`);
});
```

