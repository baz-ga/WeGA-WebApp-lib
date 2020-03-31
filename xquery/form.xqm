xquery version "3.1";

module namespace form="http://xquery.weber-gesamtausgabe.de/modules/form";

(:~
 : This is an override function for the default templates:form-control function, adding processing of the form itself
 : Processes input and select form controls, setting their value/selection to
 : values found in the request - if present.
 :)
declare function form:form-control($node as node(), $model as map(*)) as node()* {
    let $control := local-name($node)
    return
        switch ($control)
        case "form"
            return
                ()
        case "input" return
            let $type := $node/@type
            let $name := $node/@name
            let $value := templates:get-configuration($model, "templates:form-control")($templates:CONFIG_PARAM_RESOLVER)($name)
            return
                if ($value) then
                    switch ($type)
                        case "checkbox" case "radio" return
                            element { node-name($node) } {
                                $node/@* except $node/@checked,
                                attribute checked { "checked" },
                                $node/node()
                            }
                        default return
                            element { node-name($node) } {
                                $node/@* except $node/@value,
                                attribute value { $value },
                                $node/node()
                            }
                else
                    $node
        case "select" return
            let $value := templates:get-configuration($model, "templates:form-control")($templates:CONFIG_PARAM_RESOLVER)($node/@name/string())
            return
                element { node-name($node) } {
                    $node/@*,
                    for $option in $node/*[local-name(.) = "option"]
                    return
                        if (empty($value)) then
                            $option
                        else
                            element { node-name($option) } {
                                $option/@* except $option/@selected,
                                if ($option/@value = $value or $option/string() = $value) then
                                    attribute selected { "selected" }
                                else
                                    (),
                                $option/node()
                            }
                }
        default return
            $node
};

declare function templates:error-description($node as node(), $model as map(*)) {
    let $input := templates:get-configuration($model, "templates:form-control")($templates:CONFIG_PARAM_RESOLVER)("org.exist.forward.error")
    return
        element { node-name($node) } {
            $node/@*,
            try {
                parse-xml($input)//message/string()
            } catch * {
                $input
            }
        }
};