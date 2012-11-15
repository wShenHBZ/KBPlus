package com.k_int.kbplus.auth

import javax.persistence.Transient

class User {

  transient springSecurityService

  String username
  String display
  String password
  String instname
  String instcode
  String email
  String shibbScope
  boolean enabled
  boolean accountExpired
  boolean accountLocked
  boolean passwordExpired

  SortedSet affiliations

  static hasMany = [ affiliations: com.k_int.kbplus.auth.UserOrg ]
  static mappedBy = [ affiliations: 'user' ]

  static constraints = {
    username blank: false, unique: true
    password blank: false
    instname blank: true, nullable: true
    display blank: true, nullable: true
    instcode blank: true, nullable: true
    email blank: true, nullable: true
    shibbScope blank: true, nullable: true
  }

  static mapping = {
    password column: '`password`'
  }

  Set<Role> getAuthorities() {
    UserRole.findAllByUser(this).collect { it.role } as Set
  }

  def beforeInsert() {
    encodePassword()
  }

  def beforeUpdate() {
    if (isDirty('password')) {
      encodePassword()
    }
  }

  @Transient
  def getDisplayName() {
    def result = null;
    if ( display ) {
      result = display
    }
    else {
      result = username
    }
    result
  }

  protected void encodePassword() {
    password = springSecurityService.encodePassword(password)
  }

  @Transient def getAuthorizedAffiliations() {
    affiliations.findAll { (it.status == 1) || (it.status==3) }
  }

  /**
   * This method lists all the principals that convey a particular permission on a user. For example
   * Institution UHI grants "EDIT" permission to anyone with the role "Member". This is the trivial case.
   * if "UHI" joins the "SHEDL" consortia, and the "Member" link between the two also carries the "EDIT" permission,
   * then the implication is that this user will be able to edit SHEDL resources. This method traverses the directed graph
   * of objects that grant the identified permission to a user. This simplifies searching the permissions space,
   * as we're then only looking for one of a finite set.
   */
  @Transient def listPrincipalsGrantingPermission(perm) {
    Set result= new HashSet();
    def perm_obj = Perm.findByCode(perm)
    if ( perm ) {
      def c = UserOrg.createCriteria()
      def results = c.list {
	      eq("user",this)
        formalRole {
          grantedPermissions {
            eq("perm",perm_obj)
          }
        }
      }
      results.each { uo ->
        //log.debug("User has direct membership with ${uo.org.id}/${uo.org.name}")
        result.add("${uo.org.id}:${perm}")
        // We do a 1-hop addition - any outgoing combos carrying our identified permission - We should add those orgs too
        uo.org.outgoingCombos.each { oc ->
          //log.debug("Testing outgoing combo ${oc.toOrg.id}/${oc.toOrg.name} for perms of the given type")
          def has_perm = false;
          oc.type.sharedPermissions.each { sp ->
            if ( sp.perm.code==perm )
              has_perm=true;
          }
          if ( has_perm ) {
            result.add("${oc.toOrg.id}:${perm}")
          }
        }
      }
    }
    log.debug("user granted ${perm} for ${result}")
    result
  }

  def hasPerm(perm,user) {
    false
  }
}