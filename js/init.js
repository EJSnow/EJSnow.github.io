// Instance options
const parallaxElems = document.querySelectorAll(".parallax");
const parallaxOptions = {responsiveThreshold: 0};
const materialBoxElems = document.querySelectorAll(".materialboxed");
const materialBoxOptions = {inDuration: 275,outDuration: 200};
const collapsibleElems = document.querySelectorAll(".collapsible.expandable");
const collapsibleOptions = {accordion: false,};
const tabsElems = document.querySelectorAll(".tabs");
const tabsOptions = {duration: 300};
document.addEventListener("DOMContentLoaded", function() {
	// Initialize parallax effect
	const parallaxInstance = M.Parallax.init(parallaxElems, parallaxOptions);

	// Initialize Material Box image viewer
	const materialBoxInstance = M.Materialbox.init(materialBoxElems, materialBoxOptions);
	
	// Initialize collapsibles
	const collapsibleInstance = M.Collapsible.init(collapsibleElems, collapsibleOptions);
	
	// Initialize tabs
	const tabsInstance = M.Tabs.init(tabsElems, tabsOptions);
});