#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <cmark-gfm-core-extensions.h>
#include <cmark-gfm-extension_api.h>
#include <cmark-gfm.h>

#include <erl_nif.h>

typedef ErlNifBinary erl_nif_binary_t;
typedef ErlNifEnv erl_nif_env_t;
typedef ERL_NIF_TERM erl_nif_term_t;
typedef ErlNifFunc erl_nif_func_t;

typedef char cstr;
typedef int32_t i32;
typedef uint64_t u64;
#define null NULL

static const cstr *gfm_extensions[] = {
    "table", "strikethrough", "autolink", "tagfilter", "tasklist",
};

static erl_nif_term_t make_error(erl_nif_env_t *env, const cstr *message) {
  return enif_make_tuple2(env, enif_make_atom(env, "error"),
                          enif_make_string(env, message, ERL_NIF_LATIN1));
}

static int load(erl_nif_env_t *env, void **priv_data,
                erl_nif_term_t load_info) {
  cmark_gfm_core_extensions_ensure_registered();
  return 0;
}

static erl_nif_term_t to_html_nif(erl_nif_env_t *env, i32 argc,
                                  const erl_nif_term_t argv[]) {
  if (argc != 1) {
    fprintf(stderr,
            "errm_cmark_gfm_nif: to_html: arity error, expected 1, got %d\n",
            argc);
    return enif_make_badarg(env);
  }

  erl_nif_binary_t input;
  if (!enif_inspect_binary(env, argv[0], &input)) {
    fprintf(stderr, "errm_cmark_gfm_nif: to_html: input is not a binary\n");
    return enif_make_badarg(env);
  }

  cmark_parser *parser = cmark_parser_new(CMARK_OPT_DEFAULT);
  if (!parser)
    return make_error(env,
                      "errm_cmark_gfm_nif: to_html: could not create parser");

  for (u64 i = 0; i < sizeof(gfm_extensions) / sizeof(gfm_extensions[0]); i++) {
    cmark_syntax_extension *extension =
        cmark_find_syntax_extension(gfm_extensions[i]);
    if (extension)
      cmark_parser_attach_syntax_extension(parser, extension);
  }

  cmark_parser_feed(parser, (const cstr *)input.data, input.size);

  cmark_node *document = cmark_parser_finish(parser);
  if (!document) {
    cmark_parser_free(parser);
    return make_error(env,
                      "errm_cmark_gfm_nif: to_html: could not parse document");
  }

  cstr *html = cmark_render_html(document, CMARK_OPT_DEFAULT,
                                 cmark_parser_get_syntax_extensions(parser));
  cmark_node_free(document);
  cmark_parser_free(parser);

  if (!html)
    return make_error(env,
                      "errm_cmark_gfm_nif: to_html: could not render html");

  size_t len = strlen(html);
  erl_nif_binary_t output;
  if (!enif_alloc_binary(len, &output)) {
    free(html);
    return make_error(env,
                      "errm_cmark_gfm_nif: to_html: binary allocation failed");
  }

  memcpy(output.data, html, len);
  free(html);

  return enif_make_tuple2(env, enif_make_atom(env, "ok"),
                          enif_make_binary(env, &output));
}

static erl_nif_func_t nif_funcs[1] = {
    {"to_html", 1, to_html_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
};

ERL_NIF_INIT(errm_cmark_gfm_nif, nif_funcs, load, null, null, null)
