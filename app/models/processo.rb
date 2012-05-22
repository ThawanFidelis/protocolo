class Processo < ActiveRecord::Base
  attr_accessible :conteudo, :setor_origem, :requerente, :interessado,
                  :destino_inicial, :tipo_solicitacao, :setor_origem_id,
                  :requerente_id, :interessado_id, :destino_inicial_id,
                  :tipo_solicitacao_id
  belongs_to :setor_origem, class_name: 'Setor'
  belongs_to :destino_inicial, class_name: 'Setor'
  belongs_to :requerente, class_name: 'Solicitante'
  belongs_to :interessado, class_name: 'Solicitante'
  belongs_to :tipo_solicitacao
  has_many :tramitacoes
  has_many :despachos

  validates_presence_of :conteudo, :setor_origem, :requerente,
                        :destino_inicial, :tipo_solicitacao
  validates_uniqueness_of :numero_protocolo

  before_create :gerar_numero_protocolo

  state_machine :estado, :initial => :criado do
    event :enviar_para do
      transition [:criado, :recebido] => :enviado
    end

    event :receber do
      transition :enviado => :recebido
    end
  end

  def enviar_para(setor)
    tramitacoes.create!(setor_origem: setor_atual, setor_destino: setor)
    super
  end

  def receber
    tramitacoes.last.registrar_recebimento
    super
  end

  def self.filtrados_por_setor
    filtro = {}
    Setor.all.each do |setor|
      filtro[setor] = self.all.map{ |processo| processo if processo.setor_atual == setor}.delete_if{|processo| processo == nil}
    end
    return filtro
  end

  def setor_atual
    self.tramitacoes.empty? ? self.setor_origem : self.tramitacoes.last.setor_destino
  end

  def self.aguardando_recebimento_em(setor)
    Processo.all.select {|p| p.setor_atual == setor }
  end

  def ultima_tramitacao
    tramitacoes.sort_by(&:enviada_em).last
  end

  private

  def gerar_numero_protocolo
    n = (self.class.count == 0 ? 1 : self.class.last.send(:_numero) + 1).to_s
    n = "0" + n while n.size < 5
    self.numero_protocolo = "#{n}/#{Time.now.year.to_s.last(2)}"
  end

  def _numero
    numero_protocolo.split('/').first.to_i
  end

end