<script>
	import { onMount, onDestroy } from 'svelte';
	import { WebR } from 'webr';
	const webR = new WebR({ interactive: false });

	let output_dom = $state();
	let plot_dom = $state();
	let markup = $state();

	let is_webr_ready = $state(false);
	let is_output_ready = $state(false);

	let r_result = $state();

	onMount(async () => {
		markup = 'Initializing webR';
		await webR.init();

		markup = 'Installing R packages';
		await webR.installPackages(['jsonlite', 'ggplot2', 'plotly'], true);

		is_webr_ready = true;

		markup = 'Generating plot';
		r_result = await webR.evalRString(`
library(plotly)
library(ggplot2)

p <- ggplot(mpg, aes(displ, hwy, colour = class)) +
  geom_point()

plotly_json(p, pretty = FALSE)
`);

		is_output_ready = true;

		Plotly.newPlot(plot_dom, JSON.parse(r_result), {});

		markup = 'Done';
	});

	onDestroy(() => {
		// webR?.destroy(result); // TODO: garbage collection
		webR?.close();
	});
</script>

<svelte:head>
	<title>Plotly Example</title>
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.26.2/plotly.min.js"
		charset="utf-8"
	></script>
</svelte:head>

<pre><code>R is ready: {is_webr_ready}</code> | <code>Plot is ready: {is_output_ready}</code></pre>

<div>
	<pre><code id="out" bind:this={output_dom}>{@html markup}</code></pre>
</div>

<figure bind:this={plot_dom}></figure>
