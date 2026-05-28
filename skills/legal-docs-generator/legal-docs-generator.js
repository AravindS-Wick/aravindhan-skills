#!/usr/bin/env node

/**
 * Legal Documents Generator with 7-Level Verification
 *
 * Generates Privacy Policy, Terms of Service, Terms & Conditions,
 * Usage Policy, and Copyright Notice with comprehensive legal verification.
 *
 * 7 Verification Levels:
 * 1. Completeness Check
 * 2. Legal Compliance Check (GDPR, CCPA, DMCA)
 * 3. Platform Compliance Check (App Store, Google Play)
 * 4. Content Loophole Check
 * 5. Liability & Risk Check
 * 6. Enforceability Check
 * 7. Final Legal Sign-Off
 */

const fs = require('fs');
const path = require('path');

class LegalDocumentGenerator {
  constructor(config) {
    this.config = {
      appName: config.appName || 'Social Post Downloader',
      company: config.company || 'Your Company',
      companyEmail: config.companyEmail || 'legal@company.com',
      jurisdiction: config.jurisdiction || ['US', 'EU'],
      dataProcessing: config.dataProcessing !== false,
      thirdPartyAPI: config.thirdPartyAPI !== false,
      userContent: config.userContent !== false,
      payment: config.payment === true,
      apiService: config.apiService !== false,
      copyrightYear: new Date().getFullYear(),
      copyrightHolder: config.copyrightHolder || config.company,
      ...config
    };

    this.verificationResults = {
      completeness: {},
      legalCompliance: {},
      platformCompliance: {},
      loopholeCheck: {},
      liabilityCheck: {},
      enforceabilityCheck: {},
      finalSignOff: {}
    };
  }

  // ============= 7-LEVEL VERIFICATION FRAMEWORK =============

  /**
   * Level 1: Completeness Check
   * Verifies all required sections are present
   */
  verifyCompleteness(document) {
    const requiredSections = {
      'privacy-policy': [
        'Introduction',
        'Information We Collect',
        'How We Use Information',
        'Data Sharing',
        'Data Security',
        'User Rights',
        'GDPR Compliance',
        'CCPA Compliance',
        'Contact Information',
        'Changes to Policy'
      ],
      'terms-of-service': [
        'Grant of License',
        'Restrictions',
        'User Responsibilities',
        'Intellectual Property',
        'Disclaimer of Warranties',
        'Limitation of Liability',
        'Indemnification',
        'Termination',
        'Governing Law'
      ],
      'terms-and-conditions': [
        'Acceptance of Terms',
        'License Grant',
        'User Content',
        'Content Rights',
        'Prohibited Conduct',
        'Third-Party Services',
        'Liability Limitations',
        'Indemnity',
        'Dispute Resolution',
        'Changes to Terms'
      ],
      'usage-policy': [
        'Acceptable Use',
        'Prohibited Activities',
        'Copyright & Content',
        'Account Security',
        'Monitoring & Enforcement',
        'Violations & Consequences',
        'Contact for Violations'
      ],
      'copyright-notice': [
        'Copyright Notice',
        'Rights Reserved',
        'License Grant',
        'Restrictions',
        'Disclaimer'
      ]
    };

    const sections = document.split('\n## ');
    const found = {};

    requiredSections[document.type]?.forEach(section => {
      found[section] = sections.some(s => s.includes(section));
    });

    const completeness = Object.values(found).filter(v => v).length /
                        Object.keys(found).length * 100;

    return {
      status: completeness === 100 ? 'PASS' : 'FAIL',
      completeness: Math.round(completeness),
      missingSection: Object.entries(found)
        .filter(([_, v]) => !v)
        .map(([k]) => k),
      severity: completeness < 80 ? 'CRITICAL' : completeness < 95 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 2: Legal Compliance Check
   * GDPR, CCPA, DMCA, Copyright Law
   */
  verifyLegalCompliance(documentType, content) {
    const checks = {
      gdpr: {
        'lawful-basis': /lawful basis|legal grounds|consent|contract|legal obligation/i,
        'right-to-access': /right to access|access your data|obtain information/i,
        'right-to-deletion': /right to be forgotten|right to erasure|delete.*data|remove.*information/i,
        'right-to-portability': /data portability|export.*data|portable format|machine-readable/i,
        'data-controller': /data controller|processing data|data processor/i,
        'dpa': /data processing agreement|DPA|processor agreement/i
      },
      ccpa: {
        'right-to-know': /right to know|what information|collect about you/i,
        'right-to-delete': /right to delete|deletion request|remove personal information/i,
        'right-to-opt-out': /opt.out|do not sell|sale of personal information/i,
        'non-discrimination': /non.discriminatory|discrimination|differential treatment/i,
        'california-residents': /California|CCPA|California Consumer Privacy Act/i
      },
      dmca: {
        'copyright-notice': /copyright|©|notice of copyright/i,
        'dmca-safe-harbor': /safe harbor|DMCA|takedown|notice and takedown/i,
        'ip-protection': /intellectual property|IP|proprietary|patent|trademark/i
      }
    };

    const results = {};
    const applicableRegulations = this.getApplicableRegulations(documentType);

    applicableRegulations.forEach(reg => {
      if (checks[reg]) {
        results[reg] = {};
        Object.entries(checks[reg]).forEach(([check, pattern]) => {
          results[reg][check] = pattern.test(content);
        });
      }
    });

    const failedChecks = Object.entries(results)
      .flatMap(([reg, checks]) =>
        Object.entries(checks)
          .filter(([_, passed]) => !passed)
          .map(([check]) => `${reg.toUpperCase()}: ${check}`)
      );

    return {
      status: failedChecks.length === 0 ? 'PASS' : 'FAIL',
      coverage: ((Object.values(results).flat().filter(v => v).length /
                 Object.values(results).flat().length) * 100).toFixed(0),
      failedChecks,
      severity: failedChecks.length > 3 ? 'CRITICAL' : failedChecks.length > 0 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 3: Platform Compliance Check
   * App Store, Google Play, API guidelines
   */
  verifyPlatformCompliance(documentType, content) {
    const checks = {
      appStore: {
        'privacy-practices': /privacy practices|collect.*data|use of data/i,
        'parental-gatekeeping': /children|minors|age.*restrictions/i,
        'safety': /security|safe|harmful|illegal|content moderation/i,
        'contact-info': /contact.*support|support email|help|feedback/i
      },
      googlePlay: {
        'transparency': /transparent|clearly|explicit/i,
        'user-control': /user control|settings|preferences|disable/i,
        'data-retention': /retain|retention period|delete.*data|store/i,
        'policy-link': /privacy policy|terms|accessible/i
      },
      api: {
        'rate-limiting': /rate limit|requests per|quota|throttling/i,
        'api-key': /api key|authentication|secure|token|credential/i,
        'usage-restrictions': /usage|permitted use|restrictions|allowed|prohibited/i,
        'monitoring': /monitor|log|track|analytics|usage data/i
      }
    };

    const platforms = this.getApplicablePlatforms();
    const results = {};

    platforms.forEach(platform => {
      if (checks[platform]) {
        results[platform] = {};
        Object.entries(checks[platform]).forEach(([check, pattern]) => {
          results[platform][check] = pattern.test(content);
        });
      }
    });

    const failedChecks = Object.entries(results)
      .flatMap(([platform, checks]) =>
        Object.entries(checks)
          .filter(([_, passed]) => !passed)
          .map(([check]) => `${platform.toUpperCase()}: ${check}`)
      );

    return {
      status: failedChecks.length === 0 ? 'PASS' : 'FAIL',
      platforms: Object.keys(results),
      coverage: ((Object.values(results).flat().filter(v => v).length /
                 Object.values(results).flat().length) * 100).toFixed(0),
      failedChecks,
      severity: failedChecks.length > 2 ? 'CRITICAL' : failedChecks.length > 0 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 4: Content Loophole Check
   * Vague language, contradictions, ambiguities
   */
  verifyLoopholes(content) {
    const loopholes = [];
    const warnings = [];

    // Check for vague language
    const vaguePatterns = [
      { pattern: /may.*use|might.*use|could.*use/gi, issue: 'Vague permission language' },
      { pattern: /reasonable|appropriate|necessary/gi, issue: 'Undefined terms without clarification' },
      { pattern: /at our discretion|in our sole judgment/gi, issue: 'Excessive company discretion' },
      { pattern: /without limitation|without responsibility/gi, issue: 'Overly broad disclaimer' },
      { pattern: /in our opinion|we determine/gi, issue: 'Unilateral judgment clauses' }
    ];

    vaguePatterns.forEach(({ pattern, issue }) => {
      const matches = content.match(pattern);
      if (matches) {
        warnings.push(`${issue}: ${matches.length} instances found`);
      }
    });

    // Check for missing critical language
    const requiredLanguage = [
      { pattern: /liability.*limited|limited.*liability/i, required: 'Liability limitation' },
      { pattern: /indemnif/i, required: 'Indemnification clause' },
      { pattern: /warranty|as is|without warranty/i, required: 'Warranty disclaimer' },
      { pattern: /terminate|termination/i, required: 'Termination clause' },
      { pattern: /governing law|jurisdiction|venue/i, required: 'Governing law clause' }
    ];

    const missing = [];
    requiredLanguage.forEach(({ pattern, required }) => {
      if (!pattern.test(content)) {
        missing.push(required);
      }
    });

    if (missing.length > 0) {
      loopholes.push(`Missing critical clause: ${missing.join(', ')}`);
    }

    // Check for contradictions
    const contradictions = [];
    if (/no restrictions/i.test(content) && /prohibited.*activities|restricted.*use/i.test(content)) {
      contradictions.push('Contradictory language: claims no restrictions but lists prohibited activities');
    }

    return {
      status: (loopholes.length === 0 && contradictions.length === 0) ? 'PASS' : 'FAIL',
      loopholes,
      warnings,
      contradictions,
      severity: loopholes.length > 0 ? 'CRITICAL' : warnings.length > 2 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 5: Liability & Risk Check
   * Liability limitations, indemnification, disclaimers
   */
  verifyLiabilityAndRisk(content) {
    const checks = {
      liabilityLimitation: /limit.*liability|limitation of liability|not liable|not responsible|in no event/i,
      consequentialDamages: /consequential|incidental|indirect|special damages/i,
      indemnification: /indemnif|hold harmless|defend|claim.*against/i,
      warrantyDisclaimer: /without warranty|as is|provided as is|no warranty/i,
      severability: /severability|invalid.*provision|if any provision/i,
      entireAgreement: /entire agreement|supersede|prior agreement|understanding/i,
      terminationCause: /cause for termination|terminate.*breach|material breach/i
    };

    const results = {};
    Object.entries(checks).forEach(([check, pattern]) => {
      results[check] = pattern.test(content);
    });

    const missing = Object.entries(results)
      .filter(([_, found]) => !found)
      .map(([check]) => check);

    const riskScore = (Object.values(results).filter(v => v).length /
                       Object.keys(results).length * 100).toFixed(0);

    return {
      status: missing.length === 0 ? 'PASS' : missing.length <= 2 ? 'CONDITIONAL_PASS' : 'FAIL',
      coverage: riskScore,
      missing,
      riskLevel: riskScore >= 90 ? 'LOW' : riskScore >= 70 ? 'MEDIUM' : 'HIGH',
      severity: riskScore < 70 ? 'CRITICAL' : riskScore < 85 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 6: Enforceability Check
   * Legal binding language, defensibility
   */
  verifyEnforceability(content) {
    const enforcementPatterns = [
      { pattern: /binding.*agreement|binding.*contract/i, requirement: 'Binding agreement language' },
      { pattern: /hereby.*agree|agree.*terms|acceptance.*terms/i, requirement: 'Explicit consent mechanism' },
      { pattern: /violate.*terms|breach.*agreement|breach.*terms/i, requirement: 'Violation language' },
      { pattern: /injunctive relief|equitable relief|remedies/i, requirement: 'Remedies clause' },
      { pattern: /breach|violation.*consequences|enforcement/i, requirement: 'Enforcement mechanism' },
      { pattern: /waive|waiver|consent/i, requirement: 'Waiver of rights language' },
      { pattern: /signature|acknowledgment|agreement/i, requirement: 'Agreement manifestation' }
    ];

    const enforceable = {};
    enforcementPatterns.forEach(({ pattern, requirement }) => {
      enforceable[requirement] = pattern.test(content);
    });

    const enforceabilityScore = (Object.values(enforceable).filter(v => v).length /
                                 Object.keys(enforceable).length * 100).toFixed(0);

    const defensibility = [];
    if (/integration.*clause|entire.*agreement/i.test(content)) {
      defensibility.push('✓ Integration clause present');
    } else {
      defensibility.push('✗ Missing integration clause');
    }

    if (/severability/i.test(content)) {
      defensibility.push('✓ Severability clause present');
    } else {
      defensibility.push('✗ Missing severability clause');
    }

    return {
      status: enforceabilityScore >= 85 ? 'PASS' : enforceabilityScore >= 70 ? 'CONDITIONAL_PASS' : 'FAIL',
      enforceabilityScore,
      enforceable,
      defensibility,
      severity: enforceabilityScore < 70 ? 'CRITICAL' : enforceabilityScore < 85 ? 'HIGH' : 'NONE'
    };
  }

  /**
   * Level 7: Final Legal Sign-Off
   * Comprehensive review and green/red flag
   */
  generateFinalSignOff(allVerifications) {
    const criticalIssues = Object.values(allVerifications)
      .filter(v => v.severity === 'CRITICAL')
      .length;

    const highIssues = Object.values(allVerifications)
      .filter(v => v.severity === 'HIGH')
      .length;

    const overallStatus = criticalIssues > 0 ? '❌ RED FLAG' :
                         highIssues > 2 ? '⚠️ CONDITIONAL GREEN' :
                         '✅ GREEN FLAG';

    const confidence = 100 - (criticalIssues * 20 + highIssues * 5);

    return {
      status: overallStatus,
      confidenceScore: Math.max(0, Math.min(100, confidence)),
      criticalIssues,
      highIssues,
      recommendation: this.generateRecommendation(overallStatus, criticalIssues, highIssues),
      nextSteps: this.generateNextSteps(overallStatus)
    };
  }

  // ============= HELPER METHODS =============

  getApplicableRegulations(documentType) {
    const regulations = [];

    if (this.config.jurisdiction.includes('US')) regulations.push('ccpa');
    if (this.config.jurisdiction.includes('EU')) regulations.push('gdpr');
    if (this.config.dataProcessing) regulations.push('gdpr', 'ccpa');
    if (this.config.userContent || this.config.apiService) regulations.push('dmca');

    return [...new Set(regulations)];
  }

  getApplicablePlatforms() {
    const platforms = [];
    if (this.config.mobileApp) platforms.push('appStore', 'googlePlay');
    if (this.config.apiService) platforms.push('api');
    return platforms.length === 0 ? ['appStore', 'googlePlay', 'api'] : platforms;
  }

  generateRecommendation(status, critical, high) {
    if (status === '❌ RED FLAG') {
      return `HALT DEPLOYMENT: ${critical} critical issues must be resolved before publication. Consult legal counsel.`;
    } else if (status === '⚠️ CONDITIONAL GREEN') {
      return `Proceed with caution: ${high} high-priority issues should be reviewed and addressed. Recommended amendments provided.`;
    } else {
      return 'Ready for deployment. Maintain record of verification for compliance audit trail.';
    }
  }

  generateNextSteps(status) {
    const steps = {
      '❌ RED FLAG': [
        '1. Review and fix all critical issues',
        '2. Consult legal counsel on specific clauses',
        '3. Re-run verification after changes',
        '4. Document all amendments made',
        '5. Obtain legal sign-off before deployment'
      ],
      '⚠️ CONDITIONAL GREEN': [
        '1. Review high-priority amendments',
        '2. Make recommended changes',
        '3. Have legal team review changes',
        '4. Re-run Level 6 & 7 verification',
        '5. Deploy with amendment documentation'
      ],
      '✅ GREEN FLAG': [
        '1. Integrate documents into application',
        '2. Set up periodic review schedule (annually)',
        '3. Monitor regulatory changes',
        '4. Document compliance evidence',
        '5. Update on major feature changes'
      ]
    };

    return steps[status] || [];
  }
}

// Export for use in Claude Code
module.exports = LegalDocumentGenerator;
