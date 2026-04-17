class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to about_path, notice: 'お問い合わせを送信しました。ありがとうございます！'
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def contact_params
    params.expect(contact: [:name, :email, :body])
  end
end
