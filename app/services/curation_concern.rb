module CurationConcern
  module_function
  def mint_a_pid
    Sufia::Noid.namespaceize(Sufia::Noid.noidify(Sufia::IdService.mint))
  end

  def actor(curation_concern, *args)
    actor_identifier = curation_concern.class.to_s
    klass = const_get("#{actor_identifier}Actor")
    klass.new(curation_concern, *args)
  end

  def attach_file(generic_file, user, file_to_attach, name=file_to_attach.original_filename)
    Sufia::GenericFile::Actions.create_content(
      generic_file,
      file_to_attach,
      name,
      'content',
      user
    )
    Sufia.queue.push(CharacterizeJob.new(generic_file.pid))
    true
  rescue ActiveFedora::RecordInvalid => e
    Curate.configuration.fedora_integrity_message_delivery.call(pid: generic_file.pid, message:"Error Occured when attaching file, #{e.message}")
    false
  end
end
