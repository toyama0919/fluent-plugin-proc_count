# fluent-plugin-proc_count

process count check plugin for fluentd

## Examples
```
<source>
  @type proc_count
  interval 60s

  <process>
    tag proc_count.fluentd
    regexp bin/fluentd
    proc_count 2 # expect process count
  </process>

  <process>
    tag proc_count.embulk
    regexp embulk
    proc_count 1 # expect process count
  </process>
</source>

<match **>
  @type stdout
</match>
```

#### output
```
# output: proc_count.example:  {"regexp":"embulk","proc_count":0,"expect_proc_count":1,"hostname":"npc064.local"}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Information

* [Homepage](https://github.com/toyama0919/fluent-plugin-proc_count)
* [Issues](https://github.com/toyama0919/fluent-plugin-proc_count/issues)
* [Documentation](http://rubydoc.info/gems/fluent-plugin-proc_count/frames)
* [Email](mailto:toyama0919@gmail.com)

## Copyright

Copyright (c) 2016 toyama0919
