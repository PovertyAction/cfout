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
	<td>Basic</td>
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
	<td>Basic test of option <code>saving(, replace)</code></td>
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
<tr>
	<td>11</td>
	<td><code>saving()</code></td>
	<td>Check a basic differences file.</td>
</tr>
<tr>
	<td>12</td>
	<td><code>saving()</code></td>
	<td>Basic test of option <code>saving(, csv)</code></td>
</tr>
<tr>
	<td>13</td>
	<td><code>saving()</code></td>
	<td>Option <code>saving()</code> accepts the filename with or without the <code>.dta</code> file extension.</td>
</tr>
<tr>
	<td>14</td>
	<td><code>saving()</code></td>
	<td>Option <code>saving(, csv)</code> accepts the filename with or without the <code>.csv</code> file extension.</td>
</tr>
<tr>
	<td>15</td>
	<td>User mistakes</td>
	<td>Variable specified to option <code>id()</code> is not unique (either in master or in using data).</td>
</tr>
<tr>
	<td>16</td>
	<td>User mistakes</td>
	<td>Variable specified to option <code>id()</code> is <code>strL</code> (either in master or in using data).</td>
</tr>
<tr>
	<td>17</td>
	<td>String comparison</td>
	<td>Basic tests of options <code>lower</code>, <code>upper</code>, and <code>nopunct</code>.</td>
</tr>
<tr>
	<td>18</td>
	<td>User mistakes</td>
	<td>Specify both options <code>lower</code> and <code>upper</code>.</td>
</tr>
<tr>
	<td>19</td>
	<td>String comparison</td>
	<td>Specify string comparison options along with <code>nostring</code>.</td>
</tr>
<tr>
	<td>20</td>
	<td>User mistakes</td>
	<td>Specify a variable to option <code>id()</code> that exists in the master but not using data.</td>
</tr>
<tr>
	<td>21</td>
	<td>User mistakes</td>
	<td>Specify a variable to option <code>id()</code> that has a different generic type in the master and using data.</td>
</tr>
<tr>
	<td>22</td>
	<td>Basic</td>
	<td>Compare two datasets, each of which contains exactly one observation that the other does not.</td>
</tr>
<tr>
	<td>23</td>
	<td>Basic</td>
	<td>Compare two datasets, each of which contains exactly one variable that the other does not. Test the effect on <code>r(varonlym)</code>.</td>
</tr>
<tr>
	<td>24</td>
	<td>Basic</td>
	<td>Specify a variable that is numeric in one dataset and string in the other.</td>
</tr>
<tr>
	<td>25</td>
	<td>Basic</td>
	<td>Duplicate variables specified are ignored.</td>
</tr>
<tr>
	<td>26</td>
	<td>Basic</td>
	<td>Specify a variable that differs on every observation.</td>
</tr>
<tr>
	<td>27</td>
	<td>Basic</td>
	<td>Specify an ID variable in the <code>varlist</code>.</td>
</tr>
</table>
