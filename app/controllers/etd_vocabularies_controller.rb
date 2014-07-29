class EtdVocabulariesController < ApplicationController
  SUCCESS_NOTICE = "Etd Vocabulary added successfully"
  with_themed_layout
  before_filter :authenticate_user!
  before_filter :agreed_to_terms_of_service!

  respond_to(:html)
  def vocabulary
    @vocabulary ||= if (params[:id])
                      EtdVocabulary.find(params[:id])
                    else
                      EtdVocabulary.new()
                    end
  end
  helper_method :vocabulary

  def vocabularies
    @vocabularies||= if (params[:type])
                       EtdVocabulary.where( "field_type = ?", "#{params[:type]}").recent
                     else
                       EtdVocabulary.all.recent
                     end
  end

  helper_method :vocabularies

  def new
    respond_with(vocabulary)
  end

  def index
    respond_with(vocabularies)
  end

  def create
    vocabulary=EtdVocabulary.new(vocabulary_params)
    respond_to do |format|
      if vocabulary.save
        format.html { redirect_to etd_vocabularies_by_type_path(vocabulary.field_type), notice: 'Vocabulary was successfully created.' }
        format.json { render action: 'index', status: :created}
      else
        format.html { render action: 'new' }
        format.json { render json: vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_with(vocabulary)
  end

  def update
    respond_to do |format|
      if vocabulary.update(vocabulary_params)
        format.html { redirect_to vocabulary, notice: 'vocabulary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_with(vocabulary)
  end

  def destroy
    type=vocabulary.field_type
    vocabulary.destroy
    respond_to do |format|
      format.html { redirect_to etd_vocabularies_by_type_path(type) }
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vocabulary_params
    params.require(:etd_vocabulary).permit(:field_type, :field_value)
  end


end
