import { cn } from '@/lib/utils'
import { forwardRef, ButtonHTMLAttributes } from 'react'

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'white'
  size?: 'sm' | 'md' | 'lg'
  className?: string
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', ...props }, ref) => {
    return (
      <button
        className={cn(
          'inline-flex items-center justify-center rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none',
          {
            'bg-primary-600 hover:bg-primary-700 text-white focus:ring-primary-500 font-bold': variant === 'primary',
            'bg-gray-100 hover:bg-gray-200 text-gray-900 focus:ring-gray-500 font-bold' : variant === 'secondary',
            'border border-gray-300 hover:bg-gray-50 text-gray-700 focus:ring-gray-500 font-bold': variant === 'outline',
            'bg-white hover:bg-gray-50 text-primary-600 focus:ring-primary-500 shadow-sm font-bold': variant === 'white',
          },
          {
            'h-8 px-3 text-sm': size === 'sm',
            'h-10 px-4 py-2': size === 'md',
            'h-12 px-6 py-3 text-lg': size === 'lg',
          },
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)

Button.displayName = 'Button'

export { Button }