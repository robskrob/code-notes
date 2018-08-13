class Parser
  def initialize(csv)
    @csv = csv
  end

  def recipients
    CSV.parse(@csv, headers: true).map(&:to_hash)
  end
end

class Sender
  def initialize(parser, message)
    @message = message
    @parser = parser
  end

  def send
    recipients.each do |recipient|
      Mailer.invitation(recipient['name'], recipient['email'], @message).deliver
    end
  end

  private

  def recipients
    @parser.recipients
  end
end

class InvitationController < ApplicationController
  def new
  end

  def create
    parse = Parser.new(params[:csv_file].read)
    Sender.new(parser, params[:message]).send
    redirect_to new_invitation_url, notice: 'Invitations sent.'
  end
end
