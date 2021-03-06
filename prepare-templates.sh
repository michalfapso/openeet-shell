#!/bin/sh
# The certificate used in this script can be arbitrary, because the signature is overwritten later by create-signed-message.php

DIR=$(dirname $0)

mkdir -p $DIR/work

[ -d $DIR/templates ] || mkdir $DIR/templates
xmlsec1 --sign --store-references --store-signatures \
        --privkey-pem $DIR/cert/01000003.key,$DIR/cert/01000003.pem \
        --output /dev/null $DIR/data/template.xml \
        | php extract-c14n-templates.php $DIR/work/template_body_attrs.txt $DIR/templates/template_signature.txt 


xsltproc $DIR/remove-body.xsl $DIR/data/template.xml > $DIR/templates/template_request.txt

sed -e 's/ \([a-z_0-9]\+\)="@"/ @{\1}/g' $DIR/work/template_body_attrs.txt > $DIR/templates/template_body.txt

(
cd $DIR/templates
sha1sum template_body.txt template_signature.txt template_request.txt >sha1sum.txt
)
