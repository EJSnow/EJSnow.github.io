import { default as markDownItAnchor } from "markdown-it-anchor";

export const config = {
  dir: {
    output: "out",
  }
}

export default async function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("css/*");
  eleventyConfig.addPassthroughCopy("js/*");

  eleventyConfig.amendLibrary("md", (mdLib) => mdLib.use(markDownItAnchor), {level: [2, 3, 4]});
}
