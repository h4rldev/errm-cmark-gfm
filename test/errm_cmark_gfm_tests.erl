-module (errm_cmark_gfm_tests).
-include_lib ("eunit/include/eunit.hrl").

to_html_test() ->
  {ok, Html} = errm_cmark_gfm_nif:to_html(<<"# Hi">>),
  ?assertEqual(<<"<h1>Hi</h1>\n">>, Html).

gfm_extension_test() ->
  {ok, Html} = errm_cmark_gfm_nif:to_html(<<"~~gone~~">>),
  ?assertEqual(<<"<p><del>gone</del></p>\n">>, Html).
