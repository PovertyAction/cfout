cfout tests
===========

Below is a list of `cfout` tests. Unless marked otherwise, all tests are implemented in the [cscript](/cscript/cfout.do). Each test is associated with a unique positive integer ID.

Contributions of new tests are welcome. When adding a test to the cscript, please add a row to the table below. All datasets should be readable by Stata 10, the minimal supported version.

<table>
<tr>
	<th>Test ID</th>
	<th>Area</th>
	<th>Description</th>
</tr>
<tr>
	<td>1</td>
	<td>Example</td>
	<td>Help file example for <code>cfout</code> version 1.</td>
</tr>
<tr>
	<td>2</td>
	<td>Deprecated options</td>
	<td>Specify option <code>altid()</code>.</td>
</tr>
<tr>
	<td>3</td>
	<td>Deprecated options</td>
	<td>Specify option <code>format()</code>.</td>
</tr>
<tr>
	<td>4</td>
	<td>Deprecated options</td>
	<td>Specify option <code>name()</code>.</td>
</tr>
<tr>
	<td>5</td>
	<td>Deprecated options</td>
	<td>Specify option <code>replace</code>.</td>
</tr>
<tr>
	<td>6</td>
	<td>User mistakes</td>
	<td>Specify options <code>saving()</code> and <code>replace</code>.</td>
</tr>
<tr>
	<td>7</td>
	<td><code>saving()</code></td>
	<td><code>cfout</code> creates a differences file if and only if option <code>saving()</code> is specified.</td>
</tr>
<tr>
	<td>8</td>
	<td><code>saving()</code></td>
	<td>Basic test of suboption <code>saving(, replace)</code></td>
</tr>
<tr>
	<td>9</td>
	<td><code>saving()</code></td>
	<td>Run the exact same <code>cfout</code> command twice while specifying <code>saving(, replace)</code>.</td>
</tr>
<tr>
	<td>10</td>
	<td>User mistakes</td>
	<td>Run <code>cfout, saving()</code> twice without specifying <code>saving(, replace)</code>.</td>
</tr>
</table>
