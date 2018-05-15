# MiniExiftool [![Build Status](https://travis-ci.org/janfri/multi_exiftool.svg?branch=master)](https://travis-ci.org/janfri/multi_exiftool)

This library is a wrapper for the ExifTool command-line application
(http://www.sno.phy.queensu.ca/~phil/exiftool) written by Phil Harvey.
It provides the full power of ExifTool to Ruby: reading and writing of
EXIF-data, IPTC-data and XMP-data.

## Requirements

Ruby 1.9 or higher and an installation of the ExifTool
command-line application at least version 7.65.
If you run on Ruby 1.8 or with a prior exiftool version
install mini_exiftool version 1.x.x.
Instructions for installation you can find under
http://www.sno.phy.queensu.ca/~phil/exiftool/install.html .

Alternatively Wil Gieseler has bundled a meta-gem that eliminates the
need for a separate ExifTool installation. Have a look at
http://github.com/wilg/mini_exiftool_vendored or
http://rubygems.org/gems/mini_exiftool_vendored .

## Installation

First you need ExifTool (see under Requirements above). Then you can simply
install the gem with
```sh
gem install mini_exiftool
```
or simply add to the following to your Gemfile:
```ruby
gem 'mini_exiftool'
```

If you need to support older versions of Ruby or Exiftool (see Requirements above)

```sh
gem install --version "< 2.0.0" mini_exiftool
```

or if you use a Gemfile add:

```ruby
gem 'mini_exiftool', '<2.0.0'
```

## Configuration

You can manually set the exiftool command that should be used via

```ruby
MiniExiftool.command = '/path/to/my/exiftool'
```

In addition, you can also tell MiniExiftool where to store the PStore files with tags
which exiftool supports. The PStore files are used for performance issues.
Per default the PStore files are stored in a sub directory `.mini_exiftool` or
`_mini_exiftool` under your home directory.

```ruby
MiniExiftool.pstore_dir = '/path/to/pstore/dir'
```

If you're using Rails, this is easily done with

```ruby
MiniExiftool.pstore_dir = Rails.root.join('tmp').to_s
```

Important hint: if you have to change the configuration you have to do this direct
after `require 'mini_exiftool'`.

## Usage

In general MiniExiftool is very intuitive to use as the following examples show:

```ruby
# Reading meta data from a file
photo = MiniExiftool.new 'photo.jpg'
puts photo.title

# Alternative reading meta data from an IO instance
photo = MiniExiftool.new io
puts photo.title

# Writing meta data
photo = MiniExiftool.new 'photo.jpg'
photo.title = 'This is the new title'
photo.save

# Copying meta data
photo = MiniExiftool.new('photo.jpg')
photo.copy_tags_from('another_photo.jpg', :author)
```

For further information about using MiniExiftool read the Tutorial.md.
in the project root folder and have a look at the examples in directory
examples.

## Caveats

The philosophy of MiniExiftool is safety over performance.
It can not handle more than one file at once. Writing operations are
executed on a copy of the original file to have atomic writing: Either
all changed values are written or none.
To be able to assign errors to a specific tag writing operations also call
the Exiftool command-line application once for each changed tag!

In short: MiniExiftool has a very bad performance especially at write operations.

**If you work with many files it is strongly recommended not to use MiniExiftool
but instead my other gem [MultiExiftool](https://github.com/janfri/multi_exiftool).
This is designed to handle many files and do reading and writing fast.**

## Encodings

In MiniExiftool all strings are encoded in UTF-8. If you need other
encodings in your project use the String#encod* methods.

If you have problems with corrupted strings when using MiniExiftool
there are two reasons for this:

### Internal character sets

You can specify the charset in which the meta data is in the file encoded
if you read or write to some sections of meta data (i.e. IPTC, XMP ...).
It exists various options of the form *_encoding: exif, iptc, xmp, png,
id3, pdf, photoshop, quicktime, aiff, mie and vorbis.

For IPTC meta data it is recommended to set also the CodedCharacterSet
tag.

Please read the section about the character sets of the ExifTool command
line application carefully to understand what's going on
(http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q10)!

```ruby
# Using UTF-8 as internal encoding for IPTC tags and MacRoman
# as internal encoding for EXIF tags
photo = MiniExiftool.new('photo.jpg', iptc_encoding: 'UTF8',
                         exif_encoding: 'MacRoman'
# IPTC CaptionAbstract is already UTF-8 encoded
puts photo.caption_abstract
# EXIF Comment is converted from MacRoman to UTF-8
puts photo.comment

photo = MiniExiftool.new('photo.jpg', iptc_encoding: 'UTF8',
                         exif_encoding: 'MacRoman'
# When saving IPTC data setting CodedCharacterSet as recommended
photo.coded_character_set = 'UTF8'
# IPTC CaptionAbstract will be stored in UTF-8 encoding
photo.caption_abstract = 'Some text with Ümläuts'
# EXIF Comment will be stored in MacRoman encoding
photo.comment = 'Comment with Ümläuts'
photo.save
```

### Corrupt characters

You use the correct internal character set but in the string are still corrupt
characters.
This problem you can solve with the option `replace_invalid_chars`:

```ruby
# Replace all invalid characters with a question mark
photo = MiniExiftool.new('photo.jpg', replace_invalid_chars: '?')
```

## Contribution

The code is hosted in a git repository on github at
https://github.com/janfri/mini_exiftool
feel free to contribute!

## Author
Jan Friedrich <janfri26@gmail.com>

## Copyright / License
Copyright (c) 2007-2016 by Jan Friedrich

Licensed under terms of the GNU LESSER GENERAL PUBLIC LICENSE, Version 2.1,
February 1999 (see file COPYING for more details)
