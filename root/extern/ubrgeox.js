/**
 * Externs vor ubrGeo
 *
 * @externs
 */

/**
 * @private
 * @type {Object}
 */
var ubrGeox;

/**
 * Namespace.
 * @type {Object}
 */
ubrGeox.yearRangeSlider;


/**
 * Options for the profile.
 * @typedef {{
 * brushendCallback: (function(string, string)),
 * brushmoveCallback: (function(string, string))
 * }} ubrGeox.yearRangeSlider.options
 */
ubrGeox.yearRangeSlider.options;

/**
 * A callback
 * @type {function(string, string)}
 */
ubrGeox.yearRangeSlider.options.prototype.brushendCallback;

/**
 * A callback
 * @type {function(string, string)}
 */
ubrGeox.yearRangeSlider.options.prototype.brushmoveCallback;


/**
 * Information about holding libraries
 * @type {Array.<ubrGeox.Library>}
 */ 
ubrGeox.Libraries

/**
 * @typedef {{
 * isil: {string},
 * name: {string}
 * }}
 */
ubrGeox.Library

/**
 * @type {string}
 */
ubrGeox.Library.prototype.isil

/**
 * @type {string}
 */
ubrGeox.Library.prototype.name
