import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import createOrder from '@salesforce/apex/OrderController.createOrder';
import { NavigationMixin } from 'lightning/navigation';
import isCurrentUserManager from '@salesforce/apex/ProductController.isCurrentUserManager';
import createProduct from '@salesforce/apex/ProductController.createProduct';

export default class ProductList extends NavigationMixin(LightningElement) {
    
    @track products = [
        {
            Id: '001',
            Name: 'iPhone 14',
            Description__c: 'Latest Apple smartphone',
            Type__c: 'Smartphone',
            Family__c: 'Electronics',
            Image__c: 'https://example.com/iphone14.jpg',
            Price__c: 999.99
        },
        {
            Id: '002',
            Name: 'MacBook Pro',
            Description__c: 'Powerful Apple laptop',
            Type__c: 'Laptop',
            Family__c: 'Electronics',
            Image__c: 'https://example.com/macbook.jpg',
            Price__c: 2499.99
        },
        {
            Id: '003',
            Name: 'Office Chair',
            Description__c: 'Comfortable ergonomic chair',
            Type__c: 'Chair',
            Family__c: 'Furniture',
            Image__c: 'https://example.com/chair.jpg',
            Price__c: 199.99
        },
        {
            Id: '004',
            Name: 'Gaming Laptop',
            Description__c: 'High-performance gaming laptop',
            Type__c: 'Laptop',
            Family__c: 'Electronics',
            Image__c: 'https://example.com/gaminglaptop.jpg',
            Price__c: 1599.99
        },
        {
            Id: '005',
            Name: 'Wooden Table',
            Description__c: 'Elegant wooden dining table',
            Type__c: 'Table',
            Family__c: 'Furniture',
            Image__c: 'https://example.com/table.jpg',
            Price__c: 499.99
        }
    ];

    @track filteredProducts = [...this.products];
    @track cartItems = [];
    @track selectedProduct = null;
    @track isModalOpen = false;
    @track isCartModalOpen = false;

    @api recordId; // Account ID for the order
    DEFAULT_ACCOUNT_ID = "001d200000IpF13AAF";

    selectedFamily = '';
    selectedType = '';
    searchTerm = '';

    familyOptions = [
        { label: 'All Families', value: '' },
        { label: 'Electronics', value: 'Electronics' },
        { label: 'Furniture', value: 'Furniture' },
        { label: 'Clothing', value: 'Clothing' }
    ];
    
    typeOptions = [
        { label: 'All Types', value: '' },
        { label: 'Smartphone', value: 'Smartphone' },
        { label: 'Laptop', value: 'Laptop' },
        { label: 'Table', value: 'Table' },
        { label: 'Chair', value: 'Chair' }
    ];

    columns = [
        { label: 'Product Name', fieldName: 'Name' },
        { label: 'Description', fieldName: 'Description__c' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Family', fieldName: 'Family__c' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        {
            label: 'Add to Cart',
            type: 'button',
            typeAttributes: {
                label: 'Add to Cart',
                name: 'add_to_cart',
                variant: 'success'
            }
        }
    ];

    // @wire(getProducts, { familyFilter: '$selectedFamily', typeFilter: '$selectedType', searchTerm: '$searchTerm' })
    // wiredProducts({ error, data }) {
    //     if (data) {
    //         this.products = data;
    //         this.applyFilters();
    //     } else if (error) {
    //         this.products = [];
    //         this.filteredProducts = [];
    //         console.error('Error fetching products:', error);
    //     }
    // }

    applyFilters() {
        this.filteredProducts = this.products.filter(product => {
            const matchesFamily = this.selectedFamily ? product.Family__c === this.selectedFamily : true;
            const matchesType = this.selectedType ? product.Type__c === this.selectedType : true;
            const matchesSearch = this.searchTerm
                ? product.Name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
                  product.Description__c.toLowerCase().includes(this.searchTerm.toLowerCase())
                : true;

            return matchesFamily && matchesType && matchesSearch;
        });
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.addToCart(row);
    }

    addToCart(product) {
        const existingItem = this.cartItems.find(item => item.Id === product.Id);
        if (!existingItem) {
            this.cartItems = [...this.cartItems, { ...product, quantity: 1 }];
            this.showToast('Success', `${product.Name} has been added to your cart!`, 'success');
        } else {
            this.showToast('Warning', `${product.Name} is already in your cart!`, 'warning');
        }
    }

    openCartModal() {
        this.isCartModalOpen = true;
    }

    closeCartModal() {
        this.isCartModalOpen = false;
    }

    async checkoutCart() {
        
        if (!this.cartItems.length) {
            this.showToast('Error', 'Your cart is empty!', 'error');
            return;
        }

        const accountId = this.recordId || this.DEFAULT_ACCOUNT_ID;

        if (!accountId) {
            this.showToast('Error', 'No Account selected for this order!', 'error');
            return;
        }

        try {
            const orderId = await createOrder({
                cartItems: this.cartItems.map(item => ({
                    productId: item.Id,
                    price: item.Price__c,
                    quantity: item.quantity
                })),
                accountId: accountId,
            });

            this.showToast('Success', `Order ${orderId} created successfully!`, 'success');
            this.cartItems = []; // Clear the cart after checkout

            // Redirect to the created Order record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: orderId,
                    objectApiName: 'Order__c',
                    actionName: 'view'
                }
            });

        } catch (error) {
            console.error('Checkout error:', error);
            this.showToast('Error', 'Failed to create order: ' + error.body.message, 'error');
        }
    }
    
    // Fetch user permissions
    @wire(isCurrentUserManager)
    wiredManagerStatus({ error, data }) {
        if (data) {
            this.isManager = data;
        } else if (error) {
            console.error('Error fetching manager status:', error);
        }
    }

    // Open the product creation modal
    openProductModal() {
        this.isProductModalOpen = true;
    }

    // Close the modal
    closeProductModal() {
        this.isProductModalOpen = false;
    }

    // Handle input changes
    handleInputChange(event) {
        const field = event.target.name;
        this.newProduct[field] = event.target.value;
    }

    async fetchProductImage(productName) {
        const apiUrl = `http://www.glyffix.com/api/Image?word=${encodeURIComponent(productName)}`;
    
        try {
            const response = await fetch(apiUrl);
            const data = await response.json();
    
            if (data.success && data.data.length > 0) {
                return data.data[0].imageurl; // Get the first image URL
            } else {
                console.warn('No image found, using default.');
                return 'https://via.placeholder.com/150'; // Fallback placeholder image
            }
        } catch (error) {
            console.error('Error fetching product image:', error);
            return 'https://via.placeholder.com/150'; // Default image if API call fails
        }
    }
    

    // Create the new product
    async createProduct() {
        try {
            // Fetch image URL from API
            const imageUrl = await this.fetchProductImage(this.newProduct.Name);
    
            // Assign fetched image to new product
            this.newProduct.Image__c = imageUrl;
    
            // Call Apex to create product
            const product = await createProduct({ newProduct: this.newProduct });
    
            this.showToast('Success', `Product ${product.Name} created successfully!`, 'success');
            this.closeProductModal();
            this.refreshProducts(); // Refresh product list after creation
        } catch (error) {
            console.error('Error creating product:', error);
            this.showToast('Error', 'Failed to create product: ' + error.body.message, 'error');
        }
    }
    

    // Refresh product list
    refreshProducts() {
        getProducts()
            .then(data => {
                this.products = data;
            })
            .catch(error => {
                console.error('Error refreshing products:', error);
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
