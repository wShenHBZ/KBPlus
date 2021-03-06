<!doctype html>
<html>
  <head>
    <meta name="layout" content="mmbootstrap"/>
    <title>KB+ ${institution.name} ToDo List</title>
  </head>

  <body>

    <div class="container">
      <ul class="breadcrumb">
        <li> <g:link controller="home" action="index">Home</g:link> <span class="divider">/</span> </li>
        <li> <g:link controller="myInstitutions" action="changeLog" params="${[shortcode:params.shortcode]}">${institution.name} Change Log</g:link> </li>

        <li class="dropdown pull-right">
          <a class="dropdown-toggle badge" id="export-menu" role="button" data-toggle="dropdown" data-target="#" href="">Exports<b class="caret"></b></a>
          <ul class="dropdown-menu filtering-dropdown-menu" role="menu" aria-labelledby="export-menu">
            <li><g:link controller="myInstitutions" action="changeLog" params="${params+[format:'csv']}">CSV Export</g:link></li>
          </ul>
        </li>
      </ul>
    </div>

    <div class="container home-page">

      <div class="pagination" style="text-align:center">
        Showing ${num_changes} changes<br/>
        <bootstrap:paginate  action="changeLog" controller="myInstitutions" params="${params}" next="Next" prev="Prev" max="${max}" total="${num_changes}" /> <br/>
        <g:form method="get" action="changeLog" params="${params}">
          Restrict to <select name="restrict" onchange="this.form.submit()">
            <option value="">ALL</option>
            <g:each in="${institutional_objects}" var="io">
              <option value="${io[0]}" ${(params.restrict?.equals(io[0]) ? 'selected' : '')}>${io[1]}</option>
            </g:each>
          </select>
        </g:form>
      </div>

      <table class="table table-striped">
        <g:each in="${changes}" var="chg">
          <tr>
            <td><g:formatDate format="yyyy-MM-dd" date="${chg.ts}"/>
             
            </td>
            <td>
              <g:if test="${chg.subscription != null}">${message(code:'subscription.change.to')} <g:link controller="subscriptionDetails" action="index" id="${chg.subscription.id}">${chg.subscription.id} </g:link></g:if>
              <g:if test="${chg.license != null}">${message(code:'licence.change.to')} <g:link controller="licenseDetails" action="index" id="${chg.license.id}">${chg.license.id}</g:link></g:if>
              <g:if test="${chg.pkg != null}">${message(code:'package.change.to')} <g:link controller="packageDetails" action="show" id="${chg.package.id}">${chg.package.id}</g:link></g:if>
            </td>
            <td>
              ${chg.desc}
              ${chg.status} on ${chg.actionDate} by ${chg.user?.displayName}
            </td>
          </tr>
        </g:each>
      </table>

      <div class="pagination" style="text-align:center">
        <bootstrap:paginate  action="changeLog" controller="myInstitutions" params="${params}" next="Next" prev="Prev" max="${max}" total="${num_changes}" />
      </div>

    </div>


  </body>
</html>
