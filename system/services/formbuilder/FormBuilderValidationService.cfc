/**
 * Provides logic for validating form builder forms
 *
 * @autodoc
 * @singleton
 * @presideservice
 */
component {

// CONSTRUCTOR
	/**
	 * @validationEngine.inject validationEngine
	 *
	 */
	public any function init( required any validationEngine ) {
		_setValidationEngine( arguments.validationEngine );
		return this;
	}

// PUBLIC API
	/**
	 * Creates a ruleset with the validation engine
	 * and returns the name of the ruleset for the
	 * given form builder items (array)
	 *
	 * @autodoc
	 * @items.hint Array of form builder form items
	 *
	 */
	public string function getRulesetForFormItems( required array items ) {
		var rules    = [];
		var rulename = "";

		for( var item in items ) {
			if ( IsBoolean( item.type.isFormField ?: "" ) && item.type.isFormField ) {
				var config   = item.configuration ?: {};
				var itemType = item.type.id ?: "";

				rules.append( getStandardRulesForFormField( argumentCollection=config ), true );
				rules.append( getItemTypeSpecificRulesForFormField( itemType=itemType, configuration=config ), true );
			}
		}

		if ( rules.len() ) {
			rulename = "formbuilderform." & LCase( Hash( SerializeJson( rules ) ) );

			_getValidationEngine().newRuleset( name=rulename, rules=rules );
		}

		return rulename;
	}

	/**
	 * Returns an array of rules for a given form builder
	 * form field's configuration. The form builder form item's
	 * configuration should be passed as the argument
	 * collection of the function
	 *
	 * @autodoc
	 */
	public array function getStandardRulesForFormField( required string name ) {
		var rules = [];

		if ( IsBoolean( arguments.mandatory ?: "" ) && arguments.mandatory ) {
			rules.append({ fieldname=arguments.name, validator="required" });
		}

		if ( IsNumeric( arguments.maxLength ?: "" ) && arguments.maxLength > 0 ) {
			if ( IsNumeric( arguments.minLength ?: "" ) && arguments.minLength > 0 ) {
				rules.append({ fieldname=arguments.name, validator="rangelength", params={ min=Int( arguments.minLength ), max=Int( arguments.maxLength ) } });
			} else {
				rules.append({ fieldname=arguments.name, validator="maxlength", params={ max=Int( arguments.maxLength ) } });
			}
		} else if ( IsNumeric( arguments.minLength ?: "" ) && arguments.minLength > 0 ) {
			rules.append({ fieldname=arguments.name, validator="minlength", params={ min=Int( arguments.minLength ) } });
		}

		if ( IsNumeric( arguments.maxValue ?: "" ) && arguments.maxValue > 0 ) {
			if ( IsNumeric( arguments.minValue ?: "" ) && arguments.minValue > 0 ) {
				rules.append({ fieldname=arguments.name, validator="range", params={ min=Int( arguments.minValue ), max=Int( arguments.maxValue ) } });
			} else {
				rules.append({ fieldname=arguments.name, validator="maxValue", params={ max=Int( arguments.maxValue ) } });
			}
		} else if ( IsNumeric( arguments.minValue ?: "" ) && arguments.minValue > 0 ) {
			rules.append({ fieldname=arguments.name, validator="minValue", params={ min=Int( arguments.minValue ) } });
		}

		return rules;
	}

	/**
	 * Returns an array of validation rules generated by a custom rule generator for the given
	 * item type, if present.
	 *
	 * @autodoc
	 * @itemType.hint      The type of item who's rules you wish to generate
	 * @configuration.hint The saved configuration for the item who's rules you wish to generate
	 *
	 */
	public array function getItemTypeSpecificRulesForFormField( required string itemType, required struct configuration ) {
		var handlerAction = "formbuilder.item-types.#arguments.itemType#.getValidationRules";
		var coldbox       = $getColdbox();

		if ( !coldbox.handlerExists( handlerAction ) ) {
			return [];
		}

		return coldbox.runEvent(
			  event          = handlerAction
			, private        = true
			, prepostExempt  = true
			, eventArguments = { args=arguments.configuration }
		);
	}

	/**
	 * Validates the given submission data against a set of form builder form items.
	 * Returns a preside Validation framework's 'ValidationResult' object.
	 *
	 * @autodoc
	 * @formItems.hint      Array of form item definitions for the form
	 * @submissionData.hint Struct of data that has been submitted for validation
	 */
	public any function validateFormSubmission( required array formItems, required struct submissionData ) {
		var ruleset = getRulesetForFormItems( items=arguments.formItems );

		return _getValidationEngine().validate( ruleset=ruleset, data=arguments.submissionData );
	}

// GETTERS AND SETTERS
	private any function _getValidationEngine() {
		return _validationEngine;
	}
	private void function _setValidationEngine( required any validationEngine ) {
		_validationEngine = arguments.validationEngine;
	}

}