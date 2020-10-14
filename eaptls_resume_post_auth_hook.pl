# eaptls_resume_post_auth_hook.pl
#
# Two functions are available for managing data that needs to be saved
# across resumed TLS sessions:
# eap_copy_to_resume_context saves data to resume context from the current EAP context.
# eap_copy_from_resume_context fetches data from resume context to the current EAP context.

# eap_copy_from_resume_context and eap_copy_to_resume_context
# functions return 1 for success and 0 if resume context was not
# found. If the key, for example eaptls_tls_subject in the sample
# below, does not exist, it will be skipped while copying.
#
# eap_copy_to_resume_attrs returns 0 if resume context was not found,
# 1 if reply attributes were present in resume context and 2 if reply
# attributes were not present in resume context. Reply attributes are
# present for EAP-TTLS and PEAP.

# For this sample EAP-TLS was configured to save client certificate's
# Subject in EAP context.
#
# EAPTLS_CertificateVerifyHook sub {my $p = $_[5]; $p->{EAPContext}->{eaptls_tls_subject} = $_[4]; return $_[0]}

# This is an PostAuthHook for an AuthBy that does EAP-TLS.
sub {
    my $p = ${$_[0]};
    my $result = $_[2];

    return unless $$result == $main::ACCEPT;

    my $context = $p->{EAPContext};
    my $reused = $context->{eaptls_session_reuse_method};
    if ($reused == 0)
    {
	# Full TLS handshake was done. Successful inner authentication
	# was done for EAP-TTLS and PEAP. Need to store the custom
	# value for later. Get it from EAP context where it was saved
	# by EAPTLS_CertificateVerifyHook
	my $ret = Radius::AuthGeneric::eap_copy_to_resume_context($p, $context, 'eaptls_resume_test');
	main::log($main::LOG_DEBUG, "PostAuthHook: Saving Subject for TLS resume: $context->{eaptls_tls_subject} returned $ret", $p);

	# If this Hook is called from a PostAuthHook for an AuthBy for
	# EAP-TTLS or PEAP, you can add to the saved reply attributes
	# returned by inner authentication. When TLS resume is done,
	# these reply attributes are automatically added to the reply.
	#
	# Add something in the reply now and also save it for the
	# future TLS resumes:
	#$p->{rp}->add_attr('Session-Timeout', 120);
	#my $ret_rp = Radius::AuthGeneric::eap_copy_to_resume_attrs($p, $context, 'Session-Timeout', 120);
	#main::log($main::LOG_DEBUG, "PostAuthHook: Adding reply attributes for TLS resume returned $ret_rp", $p);
    }
    elsif ($reused == 1)
    {
	# TLS session was resumed. Inner authentication was not done
	# for EAP-TTLS or PEAP. Get our custom value from the
	# previously saved resume context and store it in EAP context
	my $ret = Radius::AuthGeneric::eap_copy_from_resume_context($p, $context, 'eaptls_tls_subject');
	main::log($main::LOG_DEBUG, "PostAuthHook: Fetching Subject during TLS resume returned $ret", $p);

	# If this Hook is called from a PostAuthHook for an AuthBy for
	# EAP-TTLS or PEAP, we do nothing since our reply attribute
	# was already saved in the resume context during the first
	# authentication and was now automaticaly fetched.
    }
    elsif ($reused == 2)
    {
	# TLS session was resumed. Successful inner authentication was
	# done for EAP-TTLS or PEAP. Do nothing since our custom value
	# should have already been saved when the first, and also
	# full, authentication was done. Because full authentication
	# was done, EAPTLS_CertificateVerifyHook did run and stored
	# the custom value in EAP context. We could still do sanity
	# checks here.
	main::log($main::LOG_DEBUG, "PostAuthHook: TLS session was resumed with full inner authentication", $p);
    }

    # At this point we always have certificate's Subject from the full
    # authentication available.
    main::log($main::LOG_DEBUG, "PostAuthHook: reused: $reused, Subject: $context->{eaptls_tls_subject}", $p);

    return;
}
