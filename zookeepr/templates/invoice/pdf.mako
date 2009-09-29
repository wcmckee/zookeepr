<% date_format = "<date><day>%d</day><month>%b</month><year>%Y</year></date>" %>
<invoice>
  <logo></logo>
  <number>${ c.invoice.id }</number>
  <issued>${ c.invoice.issue_date.strftime(date_format) |n}</issued>
  <due>${ c.invoice.due_date.strftime(date_format) |n}</due>

<% amt = c.invoice.total() %>
  <amount cents="${ amt }">${ h.number_to_currency(amt/100.0) }</amount>
% if c.invoice.good_payments().count() > 0:
  <paid>
<% pp = [] %>
%   for p in c.invoice.good_payments():
<%     pp.append(str(p.gateway_ref)) %>
%   endfor
    <transaction>${ '-'.join(pp) }</transaction>
  </paid>
% elif c.invoice.total() == 0:
  <zero/>
% else:
  <owed cents="${ amt }"/>
% endif
% if c.invoice.bad_payments().count() > 0:
  <badpayments/>
% endif

<%
  lines = []
  lines.append(c.invoice.person.fullname())
  if c.invoice.person.company:
    lines.append(c.invoice.person.company)

  lines.append(c.invoice.person.address1)
  if c.invoice.person.address2:
    lines.append(c.invoice.person.address2)

  if c.invoice.person.state:
    lines.append(c.invoice.person.city)
    lines.append(c.invoice.person.state + ", " + c.invoice.person.postcode)
  else:
    lines.append(c.invoice.person.city + ", " + c.invoice.person.postcode)

  lines.append(c.invoice.person.country)
  
  line_count = 0
%>

  <attn>
% for line in lines:
<%   line_count += 1 %>
    <field${ line_count }>${ line }</field${ line_count }>
% endfor

    <email>${ c.invoice.person.email_address | h }</email>
  </attn>
   
  <event>${ h.event_name() }</event>
  <contact>${ h.lca_info['contact_email'] }</contact>

  <items>
<% itemid = 0 %>
% for item in c.invoice.items:
%   if h.lca_rego['accommodation']['self_book'] != 'yes' or item.product is None or item.product.category.name != 'Accommodation':
<%   itemid += 1 %>
    <item${ itemid }>
      <description>${ item.description }</description>
      <qty>${ item.qty }</qty>
      <each cents="${ item.cost }">${ h.number_to_currency(item.cost/100.0) }</each>
      <subtotal cents="${ item.total() }">${ h.number_to_currency(item.total()/100.0) }</subtotal>
    </item${ itemid }>
%   endif
% endfor
  </items>

  <itemcount>${ itemid }</itemcount>

<% gst = int(c.invoice.total() * h.lca_info['sales_tax']) %>
  <gst cents="${ gst }">${ h.number_to_currency(gst/100.0) }</gst>

</invoice>
