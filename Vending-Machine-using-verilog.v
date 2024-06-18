`timescale 1ns / 1ps

module VendingMachine(
    input clk,                      // Clock input to synchronize operations
    input rst,                      // Reset input to initialize or reset the vending machine
    input [2:0] selected_product,   // 3-bit input for selecting the desired product
    input payment_online,           // Input signal indicating payment via online method
    input initiate,                 // Input signal to start the vending machine operation
    input abort,                    // Input signal to cancel the current operation
    input [6:0] coin_total_value,   // 7-bit input representing the total value of inserted coins

    output reg [3:0] current_state,       // 4-bit output representing the current state of the vending machine
    output reg dispense,                  // Output signal to trigger product dispensing
    output reg [6:0] change_to_return,    // 7-bit output representing the change to be returned
    output reg [6:0] selected_price       // 7-bit output indicating the price of the selected product
);

// Definition of internal states for the state machine
localparam STATE_IDLE = 4'b0000;
localparam STATE_SELECT_PRODUCT = 4'b0001;
localparam STATE_PEN_SELECTED = 4'b0010;
localparam STATE_NOTEBOOK_SELECTED = 4'b0011;
localparam STATE_COKE_SELECTED = 4'b0100;
localparam STATE_LAYS_SELECTED = 4'b0101;
localparam STATE_WATER_BOTTLE_SELECTED = 4'b0110;
localparam STATE_DISPENSE_AND_RETURN_CHANGE = 4'b0111;

// Prices for each product represented in 7-bit format
parameter PRICE_WATER_BOTTLE = 7'd20;
parameter PRICE_LAYS = 7'd35;
parameter PRICE_COKE = 7'd30;
parameter PRICE_PEN = 7'd15;
parameter PRICE_NOTEBOOK = 7'd50;

// Internal registers for state and values management
reg [3:0] state_next;              // Register to hold the next state of the state machine
reg [6:0] price_current_product;   // Register to hold the price of the currently selected product
reg [6:0] change_value;            // Register to hold the change amount to be returned

// Sequential logic for state transition and register updates
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= STATE_IDLE;        // Set to IDLE state on reset
        price_current_product <= 0;         // Reset product price register
        change_value <= 0;                  // Reset change return register
    end else begin
        current_state <= state_next;        // Update current state to next state
        price_current_product <= price_current_product; // Maintain current product price
        change_value <= change_value;       // Maintain current change return value
    end
end

// Combinational logic for determining the next state based on current state and inputs
always @(*) begin
    case (current_state)
        STATE_IDLE: begin
            if (initiate)
                state_next = STATE_SELECT_PRODUCT; // Transition to product selection state if initiate is pressed
            else if (abort)
                state_next = STATE_IDLE; // Remain in IDLE state if abort is pressed
            else 
                state_next = STATE_IDLE; // Remain in IDLE state if no action
        end    
        STATE_SELECT_PRODUCT: begin
            case (selected_product)
                3'b000: begin
                    state_next = STATE_PEN_SELECTED; // Transition to Pen selection state
                    price_current_product = PRICE_PEN; // Set product price to Pen price
                end
                3'b001: begin
                    state_next = STATE_NOTEBOOK_SELECTED; // Transition to Notebook selection state
                    price_current_product = PRICE_NOTEBOOK; // Set product price to Notebook price
                end
                3'b010: begin
                    state_next = STATE_COKE_SELECTED; // Transition to Coke selection state
                    price_current_product = PRICE_COKE; // Set product price to Coke price
                end
                3'b011: begin
                    state_next = STATE_LAYS_SELECTED; // Transition to Lays selection state
                    price_current_product = PRICE_LAYS; // Set product price to Lays price
                end
                3'b100: begin
                    state_next = STATE_WATER_BOTTLE_SELECTED; // Transition to Water bottle selection state
                    price_current_product = PRICE_WATER_BOTTLE; // Set product price to Water bottle price
                end
                default: begin
                    state_next = STATE_IDLE; // Default to IDLE state for invalid product code
                    price_current_product = 0; // Set product price to 0 for invalid selection
                end
            endcase
        end
        STATE_PEN_SELECTED, STATE_NOTEBOOK_SELECTED, STATE_COKE_SELECTED, STATE_LAYS_SELECTED, STATE_WATER_BOTTLE_SELECTED: begin
            if (abort) begin 
                state_next = STATE_IDLE; // Transition to IDLE state if abort is pressed
                change_value = coin_total_value; // Set return change to total coin value
            end
            else if (coin_total_value >= price_current_product)
                state_next = STATE_DISPENSE_AND_RETURN_CHANGE; // Transition to dispense state if sufficient coins inserted
            else if (payment_online)
                state_next = STATE_DISPENSE_AND_RETURN_CHANGE; // Transition to dispense state if online payment is made
            else
                state_next = current_state; // Remain in current state if conditions not met
        end
        STATE_DISPENSE_AND_RETURN_CHANGE: begin
            state_next = STATE_IDLE; // Transition back to IDLE state after dispensing product
            if (payment_online)
                change_value = 0; // No change to return if payment was online
            else if (coin_total_value >= price_current_product)
                change_value = coin_total_value - price_current_product; // Calculate return change if sufficient coins inserted
        end
    endcase
end

// Combinational logic for output signals based on current state
always @(*) begin
    current_state = current_state; // Output the current state
    case (current_state)
        STATE_DISPENSE_AND_RETURN_CHANGE: begin
            dispense = 1; // Activate dispense signal
            change_to_return = change_value; // Output the calculated return change
            selected_price = price_current_product; // Output the price of the selected product
        end
        default: begin
            dispense = 0; // Deactivate dispense signal
            change_to_return = 0; // Set return change to 0
            selected_price = 0; // Set product price to 0
        end
    endcase
end

endmodule
