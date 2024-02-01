# Infoboxes

DocMark:

```
[[
## TITLE
[ALT_TEXT](IMAGE_PATH)
### HEADING
CATEGORY
- CONTENT
]]
```

HTML:

```html
<div class="infobox-container">
	<div class="infobox">
		<div class="heading">
			<h2>TITLE</h2>
		</div>
		<img src="IMAGE_PATH" alt="ALT_TEXT" class="infobox-img">
		<div class="infobox-group">
			<div class="heading">
				<h3>HEADING</h3>
			</div>
			<div class="infobox-data">
				<div class="infobox-datarow">
					<p class="data-heading">CATEGORY</p>
					<ul class="data-content">
						<li>CONTENT</li>
					</ul>
				</div>
			</div>
		</div>
	</div>
</div>
```

Unique elements can only be inserted once per infobox. Generic elements can be inserted any number of times, but only within their containing element.

## Opener (`[[`)

Unique

```html
<div class="infobox-container">
<div class="infobox">
```

## Title (`## TITLE`)

Unique

```html
<div class="heading">
<h2>TITLE</h2>
</div>
```

## Image (`[ALT_TEXT](IMAGE_PATH)`)

Generic within main body.

```html
<img src="IMAGE_PATH" alt="ALT_TEXT" class="infobox-img">
```

## Category (`### CATEGORY`)

Generic within main body.

```html
<div class="infobox-group">
<div class="heading">
<h3>CATEGORY</h3>
</div>
<!--INSERT HEADING HERE-->
</div>
```

## Heading (`HEADING`)

Generic within category.

```html
<div class="infobox-data">
<div class="infobox-datarow">
<p class="data-heading">HEADING</p>
<ul class="data-content">
	<!--INSERT CONTENT HERE-->
</ul>
</div>
</div>
```

## Content (`- CONTENT`)

Generic within heading.

```html
<li>CONTENT</li>
```

## Closer (`]]`)

Unique.

```html
</div>
</div>
```