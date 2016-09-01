class ProductsController < ApplicationController
  include PayPal::SDK::REST
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  def agregar_carro

    @product = Product.find(params[:id])
    session[:carro]<< @product

     respond_to do |format|
      format.js
     end

  end

  def comprar
     

     items = []
    session[:carro].each do |item|
     item[:sku] = item[:name]
     item[:currency] = "USD"
     item[:quantity] = 1
     items << item.slice("name", "sku", "currency", "quantity", "price")
    end
 amount = items.collect{|x| x["price"]}.map(&:to_f).sum.to_i



     @payment = Payment.new({
     :intent => "sale",
     :payer => {
     :payment_method => "paypal" },
     # ###Redirect URLs
     :redirect_urls => {
     :return_url => felicitaciones_products_url,
     :cancel_url => error_products_url },
     :transactions => [{
     # Item List
     :item_list => {
     :items => items},
     :amount => {
     :total => amount,
     :currency => "USD" },
     :description => "This is the payment transaction description." }]})
     # Create Payment and return status
     if @payment.create
 
     # Redirect the user to given approval url
     @redirect_url = @payment.links.find{|v| v.method == "REDIRECT" }.href
     redirect_to @redirect_url
     else
     render json: @payment.error
     end
  end

  def felicitaciones

  @paypal_payment = PayPal::SDK::REST::Payment.find(params[:paymentId])
 if @paypal_payment.execute(payer_id: params[:PayerID])
 @amount = @paypal_payment
 .transactions
 .collect(&:amount)
 .collect(&:total)
 .map(&:to_f)
 .sum()

 render plain: ":)"
 else
 render plain: ":("
 end


  end

  def error
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :price)
    end
end
