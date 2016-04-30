[&lt;&lt; Back to the README](README.md)

# Chapter 14. Wrap Your Threads in an Abstraction

This chapter is focused on turning you away from simple apps you may run
locally and more on the real world of production.

## Single Level of Abstraction

> "One level of abstraction per function" - Bob Martin

It states that all code in a given function should be at the same level of
abstraction, so don't intermingle low-level and high-level code in the same
function. They just don't mix well.

Threads are low-level concepts with their own complexities. Your OS provides it,
and is likely not part of the domain logic of your app.

**It's best to wrap threads in an abstraction where possible.** This is a
guideline, however, and not a rule.


Rememer the simple `FileUploader` simple class from the beginning of the book?
We can make it much better if we put the abstraction in the correct place.

```rb
module Enumerable
  def concurrent_each
    threads = []

    each do |element|
      threads << Thread.new {
        yield element
      }
    end

    threads.each(&:join)
  end
end


require 'thread'
require_relative 'concurrent_each'

class FileUploader
  attr_reader :results

  def initialize(files)
    @files = files
    @results = Queue.new
  end

  def upload
    @files.concurrent_each do |(filename, file_data)|
      status = upload_to_s3(filename, file_data)
      @results << status
    end
  end

  def upload_to_s3(filename, file)
    # omitted
  end
end

uploader = FileUploader.new('boots.png'=>'data-here','shirts.png'=>'data-here')
uploader.upload

puts uploader.results.size
```

The above is a lot easier to read, at-a-glance.

## Actor Model

*page 122*
