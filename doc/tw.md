<style>
.header {
  border-bottom: 2px solid black; /* Set your desired border style */
  display: inline-block; /* Ensures the border only extends as far as the content */
}

.float-left {
  float: left;
  margin: 10px;
}

.content::after {
  content: ''; /* Create a pseudo-element */
  display: table; /* Ensures it becomes a block-level element */
  clear: both; /* Clear floats to ensure it starts below floating elements */
}

</style>

<div class="float-right">
  floating element
</div>

<div class="content">
  <h2 class="header">Your Header Here</h2>
  <p>Your text content here.</p>
</div>
