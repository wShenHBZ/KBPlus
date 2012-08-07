package com.k_int.kbplus

import grails.converters.*
import grails.plugins.springsecurity.Secured
import grails.converters.*
import org.elasticsearch.groovy.common.xcontent.*
import groovy.xml.MarkupBuilder
import com.k_int.kbplus.auth.*;

class SubscriptionDetailsController {

  def springSecurityService
  def docstoreService
  def ESWrapperService
  def gazetteerService
  def alertsService

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def index() {
    log.debug("subscriptionDetails id:${params.id}");
    def result = [:]

    def paginate_after = params.paginate_after ?: 19;
    result.max = params.max ? Integer.parseInt(params.max) : 10;
    result.offset = params.offset ? Integer.parseInt(params.offset) : 0;

    result.user = User.get(springSecurityService.principal.id)
    result.subscriptionInstance = Subscription.get(params.id)
    // result.institution = Org.findByShortcode(params.shortcode)
    result.institution = result.subscriptionInstance.subscriber
    if ( result.institution ) {
      result.subscriber_shortcode = result.institution.shortcode
    }

    def base_qry = null;

    def qry_params = [result.subscriptionInstance]

    if ( params.filter ) {
      // base_qry = " from IssueEntitlement as ie left outer join ie.tipp.title.ids ids where ie.subscription = ? and ( ( ie.tipp.title.title like ? ) or ( ids.identifier.value like ? ) )"
      // base_qry = " from IssueEntitlement as ie ie.subscription = ? and ( ( ie.tipp.title.title like ? ) or ( exists ( from ie.tipp.title.ids as io where io.tipp = ie.tipp and io.identifier.value like ? ) ) )"
      base_qry = " from IssueEntitlement as ie where ie.subscription = ? and ( ( lower(ie.tipp.title.title) like ? ) or ( exists ( from IdentifierOccurrence io where io.ti.id = ie.tipp.title.id and io.identifier.value like ? ) ) )"
      qry_params.add("%${params.filter.trim().toLowerCase()}%")
      qry_params.add("%${params.filter}%")
    }
    else {
      base_qry = " from IssueEntitlement as ie where ie.subscription = ? "
    }

    if ( ( params.sort != null ) && ( params.sort.length() > 0 ) ) {
      base_qry += "order by ie.${params.sort} ${params.order} "
    }
    // result.num_sub_rows = IssueEntitlement.countBySubscription(result.subscriptionInstance);
    result.num_sub_rows = IssueEntitlement.executeQuery("select count(ie) "+base_qry, qry_params )[0]

    // result.entitlements = IssueEntitlement.findAllBySubscription(result.subscriptionInstance, [max:result.max, offset:result.offset, sort:'tipp.title.title', order:'asc']);
    // result.entitlements = IssueEntitlement.findAllBySubscription(result.subscriptionInstance, [max:result.max, offset:result.offset, sort:params.sort, order:params.order]);
    result.entitlements = IssueEntitlement.executeQuery("select ie "+base_qry, qry_params, [max:result.max, offset:result.offset]);

    log.debug("subscriptionInstance returning...");
    result
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def subscriptionBatchUpdate() {
    def subscriptionInstance = Subscription.get(params.id)
    def formatter = new java.text.SimpleDateFormat("MM/dd/yyyy")

    params.each { p ->
      if (p.key.startsWith('_bulkflag.') ) {
        def ie_to_edit = p.key.substring(10);

        def ie = IssueEntitlement.get(ie_to_edit)

        if ( params.bulk_start_date && ( params.bulk_start_date.trim().length() > 0 ) ) {
          ie.startDate = formatter.parse(params.bulk_start_date)
        }

        if ( params.bulk_end_date && ( params.bulk_end_date.trim().length() > 0 ) ) {
          ie.endDate = formatter.parse(params.bulk_end_date)
        }

        if ( params.bulk_embargo && ( params.bulk_embargo.trim().length() > 0 ) ) {
          ie.embargo = params.bulk_embargo
        }

        if ( params.bulk_core && (params.bulk_core.trim().length() > 0 ) ) {
          ie.coreTitle = params.bulk_core
        }

        if ( params.bulk_coverage && (params.bulk_coverage.trim().length() > 0 ) ) {
          ie.coverageDepth = params.bulk_coverage
        }

        if ( ie.save(flush:true) ) {
        }
        else {
          log.error("Problem saving ${ie.errors}")
        }
      }
    }

 
    redirect action: 'index', params:[id:subscriptionInstance?.id], id:subscriptionInstance.id
  }

  @Secured(['ROLE_USER', 'IS_AUTHENTICATED_FULLY'])
  def addEntitlements() {
    log.debug("addEntitlements....");
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    result.subscriptionInstance = Subscription.get(params.id)
    result.institution = result.subscriptionInstance.subscriber

    def paginate_after = params.paginate_after ?: 19;
    result.max = params.max ? Integer.parseInt(params.max) : 10;
    result.offset = params.offset ? Integer.parseInt(params.offset) : 0;

    log.debug("filter: \"${params.filter}\"");

    if ( result.subscriptionInstance?.instanceOf ) {
      // We need all issue entitlements from the parent subscription where no row exists in the current subscription for that item.
      def basequery = null;
      def qry_params = [result.subscriptionInstance.instanceOf, result.subscriptionInstance]

      if ( params.filter ) {
        log.debug("Filtering....");
        basequery = " from IssueEntitlement as ie where ie.subscription = ? and ( not exists ( select ie2 from IssueEntitlement ie2 where ie2.subscription = ? and ie2.tipp = ie.tipp ) ) and ( ( lower(ie.tipp.title.title) like ? ) or ( exists ( select io from IdentifierOccurrence io where io.ti.id = ie.tipp.title.id and io.identifier.value like ? ) ) )"
        qry_params.add("%${params.filter.trim().toLowerCase()}%")
        qry_params.add("%${params.filter}%")
      }
      else {
        basequery = "from IssueEntitlement ie where ie.subscription = ? and not exists ( select ie2 from IssueEntitlement ie2 where ie2.subscription = ? and ie2.tipp = ie.tipp )"
      }


      result.num_sub_rows = IssueEntitlement.executeQuery("select count(ie) "+basequery, qry_params )[0]
      result.available_issues = IssueEntitlement.executeQuery("select ie ${basequery}", qry_params, [max:result.max, offset:result.offset]);
    }
    
    result
  }
  
}