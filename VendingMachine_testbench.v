`timescale 1ns / 1ps

module VendingMachine_tb();

// Inputs
reg clk;                    // Clock signal to drive the synchronous logic in the VendingMachine
reg rst;                    // Reset signal to initialize the VendingMachine to its default state
reg [6:0] coin_total_value; // 7-bit input representing the total value of coins inserted by the user
reg [2:0] selected_product; // 3-bit input for selecting one of the products available in the vending machine
reg payment_online;         // Signal indicating whether the payment is made through an online method
reg initiate;               // Signal to initiate the vending machine operation
reg abort;                  // Signal to cancel the current vending machine operation

// Outputs
wire [3:0] current_state;   // 4-bit output indicating the current state of the vending machine
wire dispense;              // Output signal to trigger the dispensing of the selected product
wire [6:0] change_to_return; // 7-bit output representing the change to be returned to the customer
wire [6:0] selected_price;  // 7-bit output indicating the price of the selected product

// Instantiate the VendingMachine module
VendingMachine dut(
    .clk(clk),                     // Connect the clock signal to the VendingMachine
    .rst(rst),                     // Connect the reset signal to the VendingMachine
    .coin_total_value(coin_total_value), // Connect the total coin value input to the VendingMachine
    .selected_product(selected_product), // Connect the selected product input to the VendingMachine
    .payment_online(payment_online),     // Connect the online payment signal to the VendingMachine
    .initiate(initiate),                 // Connect the initiate signal to the VendingMachine
    .abort(abort),                       // Connect the abort signal to the VendingMachine

    .current_state(current_state),       // Connect the current state output from the VendingMachine
    .dispense(dispense),                 // Connect the dispense signal output from the VendingMachine
    .change_to_return(change_to_return), // Connect the change to return output from the VendingMachine
    .selected_price(selected_price)      // Connect the selected price output from the VendingMachine
);

// Clock generation logic
localparam T = 10;  // Define the clock period as 10 time units
always begin
    clk = 1'b0;
    #(T/2);        // Clock low for half the period
    clk = 1'b1;
    #(T/2);        // Clock high for half the period
end

// Initial block for defining test scenarios
initial begin
    rst = 1'b1;            // Assert the reset signal to initialize the VendingMachine
    abort = 1'b0;          // Ensure the abort signal is initially deasserted
    initiate = 1'b0;       // Ensure the initiate signal is initially deasserted
    coin_total_value = 0;  // Initialize the total coin value to 0
    payment_online = 0;    // Initialize the online payment signal to 0
    #5;
    rst = 1'b0;            // Deassert the reset signal after some time
    #100;                  // Wait for the VendingMachine to stabilize

    // Test Scenario 1: Selecting Pen with online payment
    initiate = 1'b1;       // Assert the initiate signal to start a transaction
    selected_product = 3'b000; // Select Pen (product code 000)
    payment_online = 1;    // Indicate that payment is made online
    #30 initiate = 1'b0; payment_online = 0; // Deassert the initiate and online payment signals
    #50;
    
    // Test Scenario 2: Selecting Notebook with sufficient coin value
    initiate = 1'b1;       // Assert the initiate signal to start a new transaction
    selected_product = 3'b001; // Select Notebook (product code 001)
    coin_total_value = 50; // Insert coins with total value of 50 units
    #30 initiate = 1'b0;   // Deassert the initiate signal to proceed with the transaction
    #50;
    
    // Test Scenario 3: Selecting Water Bottle with sufficient coin value
    initiate = 1'b1;       // Assert the initiate signal to start a new transaction
    selected_product = 3'b100; // Select Water Bottle (product code 100)
    coin_total_value = 50; // Insert coins with total value of 50 units
    #30 initiate = 1'b0;   // Deassert the initiate signal to proceed with the transaction
    #50;
    
    // Test Scenario 4: Aborting the transaction after selecting Water Bottle
    initiate = 1'b1;       // Assert the initiate signal to start a new transaction
    selected_product = 3'b100; // Select Water Bottle (product code 100)
    coin_total_value = 50; // Insert coins with total value of 50 units
    abort = 1'b1;          // Assert the abort signal to cancel the transaction
    #30;
    
    $finish;               // End the simulation
end

endmodule


    $finish;    
end

endmodule
