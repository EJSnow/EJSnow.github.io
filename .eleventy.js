import { default as markDownItAnchor } from "markdown-it-anchor";
import { DateTime } from "luxon";

const TIME_ZONE = "America/New_York";

export const config = {
  dir: {
    output: "out",
  }
}

export default async function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("css/*");
  eleventyConfig.addPassthroughCopy("js/*");
  eleventyConfig.addPassthroughCopy("images/*")

  eleventyConfig.amendLibrary("md", (mdLib) => mdLib.use(markDownItAnchor), {level: [2, 3, 4]});

  eleventyConfig.addDateParsing(function(dateValue) {
    let localDate;
    if(dateValue instanceof Date) {
      localDate = DateTime.fromJSDate(dateValue, {zone: "utc" }).setZone(TIME_ZONE, { keepLocalTime: true });
    } else if(typeof dateValue == "string") {
      localDate = DateTime.fromISO(dateValue, { zone: TIME_ZONE });
    }
    if (localDate?.isValid === false) {
      throw new Error(`Invalid \`date\` value (${dateValue}) is invalid for ${this.page.inputPath}: ${localDate.invalidReason}`);
    }
    return localDate;
  });
  eleventyConfig.addFilter("dateOnly", async function (dateVal, locale = "en-us") {
    var date = new Date(dateVal);
    const options = { year: "numeric", month: "short", day: "numeric" };
    return date.toLocaleDateString(locale, options);
  });

  eleventyConfig.setFrontMatterParsingOptions({
    excerpt: true,
    excerpt_separator: "<!-- excerpt -->",
  });
}
