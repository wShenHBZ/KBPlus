<%@ page import="com.k_int.kbplus.Subscription" %>
<!doctype html>
<html>
  <head>
    <meta name="layout" content="mmbootstrap"/>
    <title>KB+</title>

    <r:require modules="jeditable"/>
    <r:require module="jquery-ui"/>
  </head>
  <body>

    <div class="container">
      <ul class="breadcrumb">
        <li> <g:link controller="home">KBPlus</g:link> <span class="divider">/</span> </li>
        <li>Subscription Details</li>
      </ul>
    </div>

    <div class="container">

      ${institution?.name} Subscription Taken
      <h1><g:inPlaceEdit domain="Subscription" pk="${subscriptionInstance.id}" field="name" id="name" class="newipe">${subscriptionInstance?.name}</g:inPlaceEdit></h1>

      <ul class="nav nav-pills">
        <li><g:link controller="subscriptionDetails" 
                                   action="index" 
                                   params="${[id:params.id]}">Current Entitlements</g:link></li>

        <li class="active"><g:link controller="subscriptionDetails" 
                               action="addEntitlements" 
                               params="${[id:params.id]}">Add Entitlements</g:link></li>
      </ul>

    </div>

    <g:set var="counter" value="${offset+1}" />

    <div class="container">

      <dl>
        <dt>Available Entitlements ( ${offset+1} to ${offset+(available_issues?.size())} of ${num_sub_rows} )
          <g:form action="addEntitlements" params="${params}" method="get">
            <input type="hidden" name="sort" value="${params.sort}">
            <input type="hidden" name="order" value="${params.order}">
            Filter: <input name="filter" value="${params.filter}"/><input type="submit">
          </g:form>
        </dt>
        <dd>
          <table  class="table table-striped table-bordered table-condensed">
            <thead>
              <tr>
                <th></th>
                <th>#</th>
                <g:sortableColumn params="${params}" property="tipp.title.title" title="Title" />
                <th>ISSN</th>
                <th>eISSN</th>
                <g:sortableColumn params="${params}" property="coreTitle" title="Core" />
                <g:sortableColumn params="${params}" property="startDate" title="Start Date" />
                <g:sortableColumn params="${params}" property="endDate" title="End Date" />
                <th>Embargo</th>
                <th>Coverage Depth</th>
                <th>Coverage Note</th>
              </tr>
            </thead>
            <tbody>
              <g:each in="${available_issues}" var="ie">
                <tr>
                  <td><input type="checkbox" name="_bulkflag.${ie.id}" class="bulkcheck"/></td>
                  <td>${counter++}</td>
                  <td>
                    <g:if test="${ie.tipp?.hostPlatformURL}"><a href="${ie.tipp?.hostPlatformURL}" TITLE="${ie.tipp?.hostPlatformURL}">${ie.tipp.title.title}</a></g:if>
                    <g:else>${ie.tipp.title.title}</g:else>
                  </td>
                  <td>${ie?.tipp?.title?.getIdentifierValue('ISSN')}</td>
                  <td>${ie?.tipp?.title?.getIdentifierValue('eISSN')}</td>
                  <td>${ie.coreTitle}</td>
                  <td><g:formatDate format="dd MMMM yyyy" date="${ie.startDate}"/></td>
                  <td><g:formatDate format="dd MMMM yyyy" date="${ie.endDate}"/></td>
                  <td>${ie.embargo}</td>
                  <td>${ie.coverageDepth}</td>
                  <td>${ie.coverageNote}</td>
                </tr>
              </g:each>
            </tbody>
          </table>

          <div class="paginateButtons" style="text-align:center">
            <g:if test="${available_issues}" >
              <span><g:paginate controller="subscriptionDetails" 
                                action="addEntitlements" 
                                params="${params}" next="Next" prev="Prev" 
                                max="${max}" 
                                total="${num_sub_rows}" /></span>
            </g:if>
          </div>
        </dd>
      </dl>
    </div>

    <script language="JavaScript">
      $(document).ready(function() {
        $('span.newipe').editable('<g:createLink controller="ajax" action="genericSetValue" absolute="true"/>', {
          type      : 'textarea',
          cancel    : 'Cancel',
          submit    : 'OK',
          id        : 'elementid',
          rows      : 3,
          tooltip   : 'Click to edit...'
        });
      }
    </script>
  </body>
</html>