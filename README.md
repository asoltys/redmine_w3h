# Who, What, When, and How Much?

This is a plugin for [Chiliproject](http://chiliproject.org/) that provides additional functionality in the areas of project budget management and time recording.

The plugin was originally developed to support web application development teams in the Department of [Public Works and Government Services Canada](http://www.tpsgc-pwgsc.gc.ca/).  It has been adapted for use on the public-facing Treasury Board Canada website, [Intellectual Resources Canada](http://tbs-sct.ircan-rican.gc.ca/)

The code for this plugin was adapted from a number of other Redmine/Chiliproject plugins that were originally developed by [Eric Davis](http://github.com/edavis10) of [Little Stream Software](http://littlestreamsoftware.com).  See [CREDITS](https://github.com/asoltys/redmine_w3h/blob/master/CREDITS.txt) for full details.

# Installation

Prerequisites:  

* [Chiliproject](http://github.com/chiliproject/chiliproject) v2.5.0
* [Redmine Rate](https://github.com/edavis10/redmine_rate) v0.2.1

## Downloadable archive
<code>
cd /path/to/chiliproject/vendor/plugins  
wget https://github.com/asoltys/redmine_w3h/tarball/master  
tar xvfz redmine_w3h.tar.gz  
rm redmine_w3h.tar.gz
</code>

## Using git
<code>
cd /path/to/chiliproject/vendor/plugins  
git clone https://github.com/asoltys/redmine_w3h.git
</code>

# Features

* Improved time entry form allows users to enter time for multiple projects and multiple dates without refreshing the page
* Project budget tracking module makes it possible to track project budgets through fixed price agreements.
* Separate billable rates can be defined for users on a per-project basis and are used to calculate a running Value of Work Done total against project agreements
* A todo dashboard gives a team-wide overview of who's working on what issues and in what order and allows users and managers to visually prioritize issues

# Terms and Conditions of Use

Unless otherwise noted, computer program source code of this software is covered under Crown Copyright, Government of Canada, and is distributed under the GPLv2 License.

The Canada wordmark and related graphics associated with this distribution are protected under trademark law and copyright law. No permission is granted to use them outside the parameters of the Government of Canada's corporate identity program. For more information, see http://www.tbs-sct.gc.ca/fip-pcim/index-eng.asp

Copyright title to all 3rd party software distributed with this software is held by the respective copyright holders as noted in those files. Users are asked to read the 3rd Party Licenses referenced with those assets.

# GPLv2 License

Copyright (C) 2010 Government of Canada

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
