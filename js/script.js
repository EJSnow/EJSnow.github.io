// A "simple" implentation of tabs
try {
	const tabList = document.querySelector('[role="tablist"]');
	const tabs = tabList.querySelectorAll(':scope > [role="tab"]');

	tabs.forEach((tab) => {
		tab.addEventListener("click", changeTabs);
	});

	let tabFocus = 0;

	// Change tabs using the arrow keys
	tabList.addEventListener("keydown", (e) => {
		if (e.key === "ArrowRight" || e.key === "ArrowLeft") {
			tabs[tabFocus].setAttribute("tabindex", -1);
			if (e.key === "ArrowRight") {
				tabFocus++;
				if (tabFocus >= tabs.length) {
					tabFocus = 0;
				}
			} else if (e.key === "ArrowLeft") {
				tabFocus--;
				if (tabFocus < 0) {
					tabFocus = tabs.length - 1;
				}
			}

			tabs[tabFocus].setAttribute("tabindex", 0);
			tabs[tabFocus].focus();
		}
	});

	// Change the active tab when a tab is clicked
	function changeTabs(e) {
		const targetTab = e.target;
		const tabList = targetTab.parentNode;
		const tabGroup = tabList.parentNode;
		tabList.querySelectorAll(':scope > [aria-selected="true"]').forEach((t) => t.setAttribute("aria-selected", false));
		targetTab.setAttribute("aria-selected", true);
		tabGroup.querySelectorAll(':scope > [role="tabpanel"]').forEach((p) => p.setAttribute("hidden", true));
		tabGroup.querySelector(`#${targetTab.getAttribute("aria-controls")}`).removeAttribute("hidden");
	}
} catch(error) {
	console.log("Page does not have tabs, skipping");
}

// Modal lightbox

function openModal(modalContents) {
	modalImg.src = modalContents.src;
	modalCaption.innerHTML = modalContents.alt
	modalContainer.classList.add("shown");
}
function closeModal() {
	modalContainer.classList.remove("shown");
}
const modalContainer = document.getElementById("modal");
const modalImg = document.querySelector("#modal-img > img");
const modalCaption = document.querySelector("#modal-img > figcaption");

const lightboxImgs = document.images;
for (let i = 0; i < lightboxImgs.length - 1; i++) {
	lightboxImgs[i].addEventListener("click", function(){ openModal(lightboxImgs[i]); });
}

try {
	// Table of contents population
	const headings = document.querySelectorAll("h2");
	const tocContents = document.querySelector("#toc-contents");
	
	// Iterate through each heading and add a link for it
	for (let i = 0; i < headings.length; i++) {
		let listItem = document.createElement("li");
		
		// Properly format the link
		let listURL = "#" + headings[i].getAttribute("id");
		
		let listItemLink = document.createElement("a");
		listItemLink.setAttribute("href", listURL);
		listItemLink.innerHTML = headings[i].innerHTML;

		listItem.appendChild(listItemLink);
		tocContents.appendChild(listItem);
	}
} catch(error) {
	console.log("Page does not have a TOC, skipping");
}
