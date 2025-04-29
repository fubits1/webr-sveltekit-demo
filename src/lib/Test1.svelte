<script>
	import { onMount, onDestroy } from 'svelte';
	import { WebR } from 'webr';
	import r_test from './test.R?raw';

	const webR = new WebR({ interactive: false });

	let r_output = $state();
	let markup = $state();
	let plot_dom = $state();

	let is_webr_ready = $state(false);
	let is_pkg_ready = $state(false);
	let is_output_ready = $state(false);

	onMount(async () => {
		markup = 'Initializing webR';
		await webR.init();
		is_webr_ready = true;

		markup = 'Installing R packages';
		await webR.installPackages(['jsonlite', 'ggplot2', 'plotly'], true);
		is_pkg_ready = true;

		markup = 'Generating plot';
		const r_result = await webR.evalRString(r_test);

		// console.log(r_result);

		r_output = r_result;

		is_output_ready = true;

		markup = 'Rendering Plotly plot';

		Plotly.newPlot(plot_dom, JSON.parse(r_result), {});

		markup = 'Done';
	});

	onDestroy(() => {
		// webR?.destroy(r_result); // TODO: garbage collection
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

<div>
	<pre><code>R ready: {is_webr_ready}</code> | <code>Packages ready: {is_pkg_ready}</code> | <code
			>Plot ready: {is_output_ready}</code
		></pre>
</div>

<div>
	<pre><code>{@html markup}</code></pre>
</div>

<figure bind:this={plot_dom}></figure>

{#if is_output_ready}
	<div>
		<details>
			<summary>R output</summary>
			<pre><code>{JSON.stringify(JSON.parse(r_output), null, 2)}</code></pre>
		</details>
	</div>
{/if}
