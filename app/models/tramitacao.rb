class Tramitacao < ActiveRecord::Base
  attr_accessible :setor_destino_id, :setor_origem_id, :processo_id, :setor_origem, :setor_destino

  belongs_to :setor_origem, class_name: 'Setor'
  belongs_to :setor_destino, class_name: 'Setor'
  belongs_to :processo

  validates_presence_of :setor_destino, :setor_origem, :processo

  def registrar_recebimento
    update_attribute(:recebida_em, Time.now)
  end

  def recebida?
    recebida_em.present?
  end

  def enviada_em
    created_at
  end
end
