# nbin

[!["Open Issues"](https://img.shields.io/github/issues-raw/cdr/nbin.svg)](https://github.com/cdr/nbin/issues)
[!["Version"](https://img.shields.io/npm/v/@coder/nbin.svg)](https://www.npmjs.com/package/@coder/nbin)
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](#)
[![Discord](https://discordapp.com/api/guilds/463752820026376202/widget.png)](https://discord.gg/zxSwN8Z)

nbin is a in-house binary compiler made initially for code-server but can be used by other projects as well. Unlike contemporaries like `nbin` and `nexe` we support the following that is normally not supported by them:

- Support for native node modules.
- No magic. The user specifies all customization. An example of this is overriding the filesystem.
- First-class support for multiple platforms.

## Usage

We *highly* recommend using webpack to bundle your sources. We do not scan source-files for modules to include.

When running within the binary, your application will have access to a module named [`nbin`](typings/nbin.d.ts).

Two packages are provided:
- `@coder/nbin` - available as an API to build binaries.
- `nbin` - *ONLY* available within your binary.

### Example

```ts
import { Binary } from "@coder/nbin";

const bin = new Binary({
	mainFile: "out/cli.js",
});

bin.writeFile("out/cli.js", Buffer.from("console.log('hi');"));
const output = bin.bundle();
```

### Forks

`child_process.fork()` works as expected. `nbin` will treat the compiled binary as the original node binary when the `process.send()` function is available.

### Webpack

If you are using webpack to bundle your `main`, you'll need to externalize modules.

```ts
// webpack.config.js

module.exports = {
	...
	external: {
		nbin: "commonjs nbin",
		// Additional modules to exclude
	},
};
```

### Environment

You can pass [`NODE_OPTIONS`](https://nodejs.org/api/cli.html#cli_node_options_options).

```bash
NODE_OPTIONS="--inspect-brk" ./path/to/bin
```

We also support compressed JavaScript to reduce your bundle's size, preferrably gzip.