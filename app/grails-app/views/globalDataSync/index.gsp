<!doctype html>
<html>
  <head>
    <meta name="layout" content="mmbootstrap">
    <g:set var="entityName" value="${message(code: 'package.label', default: 'Package')}" />
    <title><g:message code="default.list.label" args="[entityName]" /></title>
  </head>
  <body>

    <div class="container">
      <div class="page-header">
        <h1>Track Changes to Global Data</h1>
      </div>
      <g:if test="${flash.message}">
        <bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
      </g:if>
    </div>

    <div class="container" style="text-align:center">
      <g:form action="index" method="get" class="form-inline">
        <label>Search text</label> <input type="text" name="q" placeholder="enter search term..." value="${params.q?.encodeAsHTML()}"  />
        <input type="submit" class="btn btn-primary" value="Search" />
      </g:form><br/>
    </div>

    <div class="container">
        
      <g:if test="${items != null}">
        <div class="container" style="text-align:center">
          Records ${offset} to ${offset+items.size()} of ${globalItemTotal}
        </div>
      </g:if>
      <table class="table table-bordered table-striped">
        <thead>
          <tr>
            <g:sortableColumn property="identifier" title="${message(code: 'package.identifier.label', default: 'Identifier')}" />
            <g:sortableColumn property="name" title="${message(code: 'package.name.label', default: 'Name')}" />
            <g:sortableColumn property="desc" title="${message(code: 'package.name.label', default: 'Description')}" />
            <g:sortableColumn property="source.name" title="${message(code: 'package.name.label', default: 'Source')}" />
            <g:sortableColumn property="type" title="${message(code: 'package.name.label', default: 'Type')}" />
            <g:sortableColumn property="kbplusCompliant" title="${message(code: 'kbplusCompliant.label', default: 'KBPlus Compliant')}" />
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <g:each in="${items}" var="item">
            <tr>
              <td> <a href="${item.source.baseUrl}resource/show/${item.identifier}">${fieldValue(bean: item, field: "identifier")}</a><br/>
                   (updated: <g:formatDate date="${item.ts}" format="dd-MM-yyyy"/>) </td>
              <td> <a href="${item.source.baseUrl}resource/show/${item.identifier}">${fieldValue(bean: item, field: "name")}</a></td>
              <td> <a href="${item.source.baseUrl}resource/show/${item.identifier}">${fieldValue(bean: item, field: "desc")}</a></td>
              <td> <a href="${item.source.uri}?verb=getRecord&identifier=${item.identifier}&metadataPrefix=${item.source.fullPrefix}">${item.source.name}</a></td>
              <td> <a href="${item.source.baseUrl}search/index?qbe=g:packages">${item.displayRectype}</a></td>
              <td>${item.kbplusCompliant?.value}</td>
              <td><g:link action="newCleanTracker" controller="globalDataSync" id="${item.id}" class="btn btn-success">Track(New)</g:link>
                  <g:link action="selectLocalPackage" controller="globalDataSync" id="${item.id}" class="btn btn-success">Track(Merge)</g:link></td>
            </tr>
            <g:each in="${item.trackers}" var="tracker">
              <tr>
                <td colspan="6">
                  -> Tracking using id
                  <g:if test="${tracker.localOid != null}">
                    <g:if test="${tracker.localOid.startsWith('com.k_int.kbplus.Package')}">
                      <g:link controller="packageDetails" action="show" id="${tracker.localOid.split(':')[1]}">${tracker.name?:'No tracker name'}</g:link>
                    </g:if>
                  </g:if>
                  <g:else>No tracker local oid</g:else>
                </td>
              </tr>
            </g:each>
          </g:each>
        </tbody>
      </table>
      <div class="pagination">
        <bootstrap:paginate  action="index" controller="globalDataSync" params="${params}" next="Next" prev="Prev" max="${max}" total="${globalItemTotal}" />
      </div>
    </div>
  </body>
</html>
