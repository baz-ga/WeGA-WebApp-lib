xquery version "3.1" encoding "UTF-8";

(:~
 : XQuery module for processing names
 : 
 : 
~:)
module namespace name="http://xquery.weber-gesamtausgabe.de/modules/name";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function name:person.get.name($person as node()?, $form as xs:string) as xs:string {
    let $persName.reg := $person/tei:persName[@type = 'reg']
    let $persName.full := $person/tei:persName[@type = 'full']
    let $form.reg := 
        if($persName.reg/tei:surname != '' and $persName.reg/tei:forename !='') then 
            $persName.reg/tei:surname || ', ' || string-join(($persName.reg/tei:forename), ' ')
        else if($persName.reg != '') then
            $persName.reg
        else if($persName.full/tei:surname != '' and $persName.full/tei:forename !='') then
            $persName.full/tei:surname || ', ' || string-join(($persName.full/tei:forename), ' ')
        else 'No name available'
    let $form.nat :=
        if($persName.reg/tei:surname != '' and $persName.reg/tei:forename !='') then
            string-join(($persName.reg/tei:forename), ' ') || ' ' || $persName.reg/tei:surname
        else if($persName.reg != '') then
            $persName.reg
        else if($persName.full/tei:surname != '' and $persName.full/tei:forename !='') then
            string-join(($persName.full/tei:forename), ' ') || ' ' || $persName.full/tei:surname
        else 'No name available'
    let $form.sort := lower-case(translate($persName.reg, ' ,', ''))
    
    return
        switch($form)
            case 'reg' return $form.reg
            case 'nat' return $form.nat
            case 'sort' return $form.sort
            default return if($persName.reg != '') then $persName.reg else $persName.full
};