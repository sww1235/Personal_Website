/** @type {import('stylelint').Config} */
export default {
	rules: {
		"at-rule-no-deprecated": true,
		"declaration-property-value-keyword-no-deprecated": true,
		"no-descending-specificity": true,
		"declaration-block-no-duplicate-custom-properties": true,
		"declaration-block-no-duplicate-properties": [
			true, {
				ignore: [
				"consecutive-duplicates-with-different-values"
				]
			}
		],
		"font-family-no-duplicate-names": true,
		"keyframe-block-no-duplicate-selectors": true,
		"no-duplicate-at-import-rules": true,
		"no-duplicate-selectors": true,
		"block-no-empty": true,
		"comment-no-empty": true,
		"no-empty-source": true,
		"at-rule-prelude-no-invalid": true,
		"color-no-invalid-hex": true,
		"function-calc-no-unspaced-operator": true,
		"keyframe-declaration-no-important": true,
		"media-query-no-invalid": true,
		"named-grid-areas-no-invalid": true,
		"no-invalid-double-slash-comments": true,
		"no-invalid-position-at-import-rule": true,
		"string-no-newline": true,
		"syntax-string-no-invalid": true,
		"no-irregular-whitespace": true,
		"custom-property-no-missing-var-function": true,
		"font-family-no-missing-generic-family-keyword": true,
		"function-linear-gradient-no-nonstandard-direction": true,
		"function-name-case": "lower",
		"declaration-block-no-shorthand-property-overrides": true,
		"selector-anb-no-unmatchable": true,
		"annotation-no-unknown": true,
		"at-rule-descriptor-no-unknown": true,
		"at-rule-descriptor-value-no-unknown": true,
		"at-rule-no-unknown": true,
		"declaration-property-value-no-unknown": true,
		"function-no-unknown": true,
		"media-feature-name-no-unknown": true,
		"media-feature-name-value-no-unknown": true,
		"no-unknown-animations": true,
		"no-unknown-custom-media": true,
		"no-unknown-custom-properties": true,
		"property-no-unknown": true,
		"selector-pseudo-class-no-unknown": true,
		"selector-pseudo-element-no-unknown": true,
		"selector-type-no-unknown": true,
		"unit-no-unknown": true,
		"at-rule-allowed-list": null,
		"at-rule-disallowed-list": null,
		"at-rule-no-vendor-prefix": true,
		"at-rule-property-required-list": null,
		"color-hex-alpha": "always",
		"color-named": "always-where-possible",
		"color-no-hex": true,
		"comment-word-disallowed-list": null,
		"declaration-no-important": true,
		"declaration-property-unit-allowed-list": null,
		"declaration-property-unit-disallowed-list": null,
		"declaration-property-value-allowed-list": null,
		"declaration-property-value-disallowed-list": null,
		"function-allowed-list": null,
		"function-disallowed-list": null,
		"function-url-no-scheme-relative": true,
		"function-url-scheme-allowed-list": null,
		"function-url-scheme-disallowed-list": null,
		"length-zero-no-unit": true,
		"media-feature-name-allowed-list": null,
		"media-feature-name-disallowed-list": null,
		"media-feature-name-no-vendor-prefix": true,
		"media-feature-name-unit-allowed-list": null,
		"media-feature-name-value-allowed-list": null,
		"property-allowed-list": null,
		"property-disallowed-list": null,
		"property-no-vendor-prefix": true,
		"rule-selector-property-disallowed-list": null,
		"selector-attribute-name-disallowed-list": null,
		"selector-attribute-operator-allowed-list": null,
		"selector-attribute-operator-disallowed-list": null,
		"selector-combinator-allowed-list": null,
		"selector-combinator-disallowed-list": null,
		"selector-disallowed-list": null,
		"selector-no-qualifying-type": null,
		"selector-no-vendor-prefix": true,
		"selector-pseudo-class-allowed-list": null,
		"selector-pseudo-class-disallowed-list": null,
		"selector-pseudo-element-allowed-list": null,
		"selector-pseudo-element-disallowed-list": null,
		"unit-allowed-list": null,
		"unit-disallowed-list": null,
		"value-no-vendor-prefix": true,
		"function-name-case": "lower",
		"selector-type-case": "lower",
		"value-keyword-case": "lower",
		"at-rule-empty-line-before": "always",
		"comment-empty-line-before": "always",
		"custom-property-empty-line-before": "never",
		"declaration-empty-line-before": [
			"never", {
			except: ["after-comment"]
			}

		],
		"rule-empty-line-before": [
			"always",{
				ignore: [
					"after-comment",
					"first-nested"
				]
			}
		],
		"declaration-block-single-line-max-declarations": 1,
		"declaration-property-max-values": {},
		//TODO: decide on a value here
		"max-nesting-depth": 5,
		"number-max-precision": 2,
		//TODO: decide on value here
		"selector-max-attribute": 2,
		//TODO: decide on value here
		"selector-max-class": 2,
		//TODO: decide on value here
		"selector-max-combinators": 2,
		//TODO: decide on value here
		"selector-max-compound-selectors": 2,
		//TODO: decide on value here
		"selector-max-id": 2,
		//TODO: decide on value here
		"selector-max-pseudo-class": 2,
		//TODO: decide on value here
		"selector-max-specificity": null,
		//TODO: decide on value here
		"selector-max-type": 2,
		//TODO: decide on value here
		"selector-max-universal": 2,
		//TODO: decide on value here
		"time-min-milliseconds": 100,
		"alpha-value-notation": "percentage",
		"color-function-alias-notation": "without-alpha",
		"color-function-notation": "modern",
		"color-hex-length": "long",
		"font-weight-notation": "named-where-possible",
		"hue-degree-notation": "angle",
		"import-notation": "url",
		"keyframe-selector-notation": "keyword",
		"lightness-notation": "percentage",
		"media-feature-range-notation": "context",
		"selector-not-notation": "complex",
		"selector-pseudo-element-colon-notation": "double",
		//"comment-pattern": "",
		//"container-name-pattern": "",
		//"custom-media-pattern": "",
		//"custom-property-pattern": "",
		//"keyframes-name-pattern": "",
		//"layer-name-pattern": "",
		//"selector-class-pattern": "",
		//"selector-id-pattern": "",
		//"selector-nested-pattern: "",
		"font-family-name-quotes": "always-where-recommended",
		"function-url-quotes":[
			"always",{
				except:["empty"]
			}
		],
		"selector-attribute-quotes": "always",
		"declaration-block-no-redundant-longhand-properties": true,
		"shorthand-property-no-redundant-values": true,
		"comment-whitespace-inside": "always"
	}
};
