# Mini Tutorial


## Installation

* Installing the ExifTool command-line application from Phil Harvey
  (see http://www.sno.phy.queensu.ca/~phil/exiftool/install.html)
* Installing the Ruby library (`gem install mini_exiftool`)


## Lesson 1: Reading Meta Data

### A Simple Example

```ruby
require 'mini_exiftool'

photo = MiniExiftool.new 'photo.jpg'
puts photo['DateTimeOriginal']
```

### Smart Tag Names
In the example above we use `photo['DateTimeOriginal']` to
get the value for the time the photo was taken. But tag names are not
case sensitive and additional underlines are also irrelevant. So
following expressions are equivalent:
```ruby
photo['DateTimeOriginal']
photo['datetimeoriginal']
photo['date_time_original']
```

It is also possible to use symbols:
```ruby
 photo[:DateTimeOriginal]
 photo[:datetimeoriginal]
 photo[:date_time_original]
```

### Nicer Access Via Dynamic Methods

Using the []-method is the safest way to access to values of tags
(e. g. Self-timer you can only access this way) but the smarter way is
using dynamic method access. You can write:
```ruby
photo.datetimeoriginal
```
or also
```ruby
photo.date_time_original
```

### Value Types

Following types of values are at the moment supported:
* Array (e. g. Keywords => ['tree', 'gras'])
* Integer (e. g. ISO => 400)
* Float (e. g. FNumber => 9.5)
* String (e. g. Model => DYNAX 7D)
* Time (e. g. DateTimeOriginal => 2005:09:13 20:08:50)

Be aware, if there is only one value in a tag which can hold multiple
values the result isn't an array! But you can get one with the Array
method:
```ruby
# only _one_ keyword
p1 = MiniExiftool.new 'p1.jpg'
p1.keywords # => 'red'
# _more than one_ keywords
p3 = MiniExiftool.new 'p3.jpg'
p3.keywords # => ['red', 'yellow', 'green']

# if we want to get an array in both cases and don't know
# if there is one ore more values set let's take Array()
Array(p1.keywords) # => ['red']
Array(p3.keywords) # => ['red', 'yellow', 'green']
```

### Using options

The ExifTool command-line application has an option (-n) to get values
as numbers if possible, in MiniExiftool you can do this with setting
the `:numerical` option to `true` while generating a new
instance with new or using the `numerical=`-method
combining with calling `reload`.

Let's look at an example:
```ruby
# standard: numerical is false
photo = MiniExiftool.new 'photo.jpg'
photo.exposure_time # => '1/60 (Rational)
# now with numerical is true
photo.numerical = true
photo.reload
photo.exposure_time # => 0.01666667 (Float)
```

This behaviour can be useful if you want to do calculations on the
value, if you only want to show the value the standard behaviour is
maybe better.

The Time class of Ruby cannot handle timestamps before 1st January 1970
on some platforms. If there are timestamps in files before this date it
will result in an error. In this case we can set the option
`:timestamps` to `DateTime` to use DateTime objects instead
of Time objects.

There is another option `:composite`. If this is set to
`false` the composite tags are not calculated by the exiftool
command-line application (option -e).

Further options are
* `:ignore_minor_errors` to ignore minor
  errors (See -m-option of the exiftool command-line application,
  default is `false`)
* `:coord_format` set format for GPS coordinates (See
  -c-option of the exiftool command-line application, default is `nil`
  that means exiftool standard)
* `:fast` useful when reading JPEGs over a slow network connection
  (See -fast-option of the exiftool command-line application, default is `false`)
* `:fast2` useful when reading JPEGs over a slow network connection
  (See -fast2-option of the exiftool command-line application, default is `false`)
* `:replace_invalid_chars` replace string for invalid
  UTF-8 characters or `false` if no replacing should be done,
  default is `false`
* `:exif_encoding`, `:iptc_encoding`,
  `:xmp_encoding`, `:png_encoding`,
  `:id3_encoding`, `:pdf_encoding`,
  `:photoshop_encoding`, `:quicktime_encoding`,
  `:aiff_encoding`, `:mie_encoding`,
  `:vorbis_encoding` to set this specific encoding (see
  -charset option of the exiftool command-line application, default is
  `nil`: no encoding specified)

### Using an IO instance

```ruby
require 'mini_exiftool'
require 'open3'

# Using external curl command
input, output = Open3.popen2("curl -s http://www.url.of.a.photo")
input.close
photo = MiniExiftool.new output
puts photo['ISO']
```

The kind of the parameter `filename_or_io` is determined via duck typing:
if the argument responds to `to_str` it is interpreted as filename, if it
responds to `read` it is interpreted es IO instance.
Attention: If you use an IO instance then writing of values is not supported!

Look at the show_speedup_with_fast_option example in the MiniExiftool examples
directory for more details about using an IO instance.


## Lesson 2: Writing Meta Data

### Also A Very Simple Example

```ruby
require 'mini_exiftool'

photo = MiniExiftool.new 'photo.jpg'
photo.comment = 'hello world'
photo.save
```


### Save Is Atomar

If you have changed several values and call the `save`-method either
all changes will be written to the file or nothing. The return value
of the `save`-method is `true` if all values are written to the file
otherwise save returns `false`. In the last case you can use the
`errors`-method which returns a hash of the tags which values couldn't
be written with an error message for each of them.


### Interesting Methods

Have a look at the `changed?`-method for checking if the
value of a specific tag is changed or a changing in general is
done. In the same way the `revert`-method reverts the value of a
specific tag or in general all changes.

You should also look at the rdoc information of MiniExiftool.


## Lesson 3: Copying Meta Data

### Examples

```ruby
require 'mini_exiftool'

photo = MiniExiftool.new('photo.jpg')

# Update the author tag of photo.jpg with the value of the author tag
# of another_photo.jpg
photo.copy_tags_from('another_photo.jpg', 'Author')

# It's also possible to use symbols and case is also not meaningful
photo.copy_tags_from('another_photo.jpg', :author)

# Further more than one tag can be copied at once
photo.copy_tags_from('another_photo', %w[author copyright])
```

Look at the file copy_icc_profile.rb in the examples folder of MiniExiftool.


## Further Examples

Have a look in the examples folder of MiniExiftool.
