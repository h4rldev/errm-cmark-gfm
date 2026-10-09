-module (errm_cmark_gfm_nif).
-export ([to_html/1]).
-on_load (init/0).

-spec init() -> ok.
init() ->
  Path = errm_cmark_gfm_nif_loader:path(errm_cmark_gfm, "errm_cmark_gfm_nif"),
  case erlang:load_nif(Path, 0) of
    ok -> ok;
    {error, Reason} -> erlang:error({nif_load_failed, Path, Reason})
  end.


-spec to_html(Markdown :: binary()) -> {ok, binary()} | {error, binary()}.
to_html(_Markdown) -> erlang:nif_error(not_loaded).
