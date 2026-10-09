# Errm... cmark-gfm!

An Erlang library exposing [cmark-gfm](https://github.com/github/cmark-gfm)
parsing/rendering through a NIF.

## Dependencies

- Erlang/OTP 28 or higher
- libcmark-gfm

## How to use

```erlang
{ok, Html} = errm_cmark_gfm_nif:to_html(<<"# Hello **world**">>).
```

## License

This project is licensed under the BSD-3 Clause license - See the [LICENSE](LICENSE) file for details.